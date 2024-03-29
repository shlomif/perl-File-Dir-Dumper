package File::Dir::Dumper::Scanner;

use warnings;
use strict;
use autodie;

use 5.012;

use parent 'File::Dir::Dumper::Base';

use Carp ();

use File::Find::Object ();
use Devel::CheckOS     qw( os_is );

use POSIX      qw(strftime);
use List::Util qw(min);

use Class::XSAccessor accessors => {
    _digest_cache => '_digest_cache',
    _digests      => '_digests',
    _file_find    => '_file_find',
    _group_cache  => '_group_cache',
    _last_result  => '_last_result',
    _queue        => '_queue',
    _reached_end  => '_reached_end',
    _result       => '_result',
    _user_cache   => '_user_cache',
};

use Digest ();

=head1 NAME

File::Dir::Dumper::Scanner - scans a directory and returns a stream of Perl
hash-refs

=head1 SYNOPSIS

    use File::Dir::Dumper::Scanner ();

    my $scanner = File::Dir::Dumper::Scanner->new(
        {
            dir => $dir_pathname
        }
    );

    while (defined(my $token = $scanner->fetch()))
    {
    }

=head1 METHODS

=head2 $self->new({ dir => $dir_path, digests => [LIST]})

Scans the directory $dir_path with the L<Digest>'s digests as contained
in the list of strings pointed by the digests array reference. C<digests>
is optional.

=head2 my $hash_ref = $self->fetch()

Outputs the next token as a hash ref.

=cut

sub _init
{
    my $self = shift;
    my $args = shift;

    my $dir_to_dump = $args->{dir};

    $self->_file_find(
        File::Find::Object->new(
            {
                followlink => 0,
            },
            $dir_to_dump,
        )
    );

    $self->_queue( [] );

    $self->_add(
        {
            type        => "header",
            dir_to_dump => $dir_to_dump,
            stream_type => "Directory Dump"
        }
    );

    $self->_digests( undef() );
    if ( exists( $args->{digests} ) )
    {
        my $digests = {};
        foreach my $d ( @{ $args->{digests} } )
        {
            if ( exists $digests->{$d} )
            {
                Carp::confess("Duplicate digest '$d'!");
            }
            $digests->{$d} = 1;
        }
        if ( !%$digests )
        {
            Carp::confess("The list of digests is empty.");
        }
        $self->_digests( [ sort { $a cmp $b } keys %$digests ] );
    }
    my $base = ( $args->{digest_cache} || 'Dummy' );
    if ( $base !~ /\A[A-Za-z_][A-Za-z_0-9]*\z/ )
    {
        Carp::confess("Invalid digest_cache format.");
    }
    my $cl = "File::Dir::Dumper::DigestCache::$base";
    ## no critic
    eval "require $cl";
    ## use critic
    if ($@)
    {
        die $@;
    }
    $self->_digest_cache(
        scalar $cl->new(
            {
                params => ( $args->{digest_cache_params} || +{} ),

            }
        )
    );

    $self->_user_cache( {} );
    $self->_group_cache( {} );

    return;
}

sub _add
{
    my $self  = shift;
    my $token = shift;

    push @{ $self->_queue() }, $token;

    return;
}

sub fetch
{
    my $self = shift;

    if ( !@{ $self->_queue() } )
    {
        $self->_populate_queue();
    }

    return shift( @{ $self->_queue() } );
}

sub _up_to_level
{
    my $self         = shift;
    my $target_level = shift;

    if ( my $last_result = $self->_last_result() )
    {

        for my $level (
            reverse( $target_level .. $#{ $last_result->dir_components() } ) )
        {
            $self->_add(
                {
                    type  => "updir",
                    depth => $level + 1,
                }
            );
        }

    }
    return;
}

sub _find_new_common_depth
{
    my $self = shift;

    my $result      = $self->_result();
    my $last_result = $self->_last_result();
    return 0 if ( ( !$last_result ) or ( !$result ) );
    my $depth = 0;

    my $upper_limit = min(
        scalar( @{ $last_result->dir_components() } ),
        scalar( @{ $result->dir_components() } ),
    );

FIND_I:
    while ( $depth < $upper_limit )
    {
        if ( $last_result->dir_components()->[$depth] ne
            $result->dir_components()->[$depth] )
        {
            last FIND_I;
        }
    }
    continue
    {
        $depth++;
    }

    return $depth;
}

BEGIN
{
    if ( os_is('Unix') )
    {
        *_my_getpwuid = sub {
            my $uid = shift;
            return scalar( getpwuid($uid) );
        };
        *_my_getgrgid = sub {
            my $gid = shift;
            return scalar( getgrgid($gid) );
        };
    }
    else
    {
        *_my_getpwuid = sub { return "unknown"; };
        *_my_getgrgid = sub { return "unknown"; };
    }
}

sub _get_user_name
{
    my $self = shift;
    my $uid  = shift;

    if ( !exists( $self->_user_cache()->{$uid} ) )
    {
        $self->_user_cache()->{$uid} = _my_getpwuid($uid);
    }

    return $self->_user_cache()->{$uid};
}

sub _get_group_name
{
    my $self = shift;
    my $gid  = shift;

    if ( !exists( $self->_group_cache()->{$gid} ) )
    {
        $self->_group_cache()->{$gid} = _my_getgrgid($gid);
    }

    return $self->_group_cache()->{$gid};
}

sub _calc_file_digests_key
{
    my ( $self, $stat ) = @_;

    my $digests = $self->_digests;

    if ( !defined $digests )
    {
        return [];
    }
    my $result = $self->_result();
    my $path   = $result->path;
    my $ret    = $self->_digest_cache->get_digests(
        {
            path    => $result->full_components,
            mtime   => $stat->[9],
            digests => $digests,
            calc_cb => sub {
                my %ret;
                foreach my $d (@$digests)
                {
                    my $o = Digest->new($d);
                    open my $fh, '<', $path;
                    binmode $fh;
                    $o->addfile($fh);
                    $ret{$d} = $o->hexdigest;
                    close($fh);
                }
                return \%ret;
            },
        }
    );
    return [ digests => $ret, ];
}
my $PERM_MASK = oct('07777');

sub _calc_file_or_dir_token
{
    my $self = shift;

    my $result = $self->_result();

    my @stat = stat( $result->path() );

    if ( not @stat )
    {
        Carp::confess(
            "Could not successfully stat <<@{[$result->path()]}>> - $!");
    }

    return {
        filename => $result->full_components()->[-1],
        depth    => scalar( @{ $result->full_components() } ),
        perms    => sprintf( "%04o", ( $stat[2] & $PERM_MASK ) ),
        mtime    => strftime( "%Y-%m-%dT%H:%M:%S", localtime( $stat[9] ) ),
        user     => $self->_get_user_name( $stat[4] ),
        group    => $self->_get_group_name( $stat[5] ),
        (
            $result->is_dir()
            ? ( type => "dir", )
            : (
                type => "file",
                size => $stat[7],
                @{ $self->_calc_file_digests_key( \@stat ) },
            )
        ),
    };
}

sub _populate_queue
{
    my $self = shift;

    if ( $self->_reached_end() )
    {
        return;
    }

    $self->_result( $self->_file_find->next_obj() );

    if ( !$self->_last_result() )
    {
        $self->_add( { type => "dir", depth => 0 } );
        if ( !$self->_result() )
        {
            $self->_add( { type => "footer" } );

            $self->_reached_end(1);
        }
    }
    elsif ( !$self->_result() )
    {
        if ( $self->_last_result() )
        {
            $self->_up_to_level(-1);
        }

        $self->_add( { type => "footer" } );

        $self->_reached_end(1);
    }
    else
    {
        $self->_up_to_level( $self->_find_new_common_depth() );

        $self->_add( $self->_calc_file_or_dir_token() );
    }

    $self->_last_result( $self->_result() );
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@cpan.org> >>

=cut

1;    # End of File::Dir::Dumper
