package File::Dir::Dumper::DigestCache::FS;

use warnings;
use strict;
use autodie;

use parent 'File::Dir::Dumper::Base';

use 5.012;

use Class::XSAccessor accessors => { _path => '_path', };

use File::Basename qw/ dirname /;
use File::Spec ();
use File::Path 2.00 qw/ make_path /;
use JSON::MaybeXS ();

=head1 NAME

File::Dir::Dumper::DigestCache::FS - digest cache for
L<File::Dir::Dumper> that uses the file system.

=head1 SYNOPSIS

B<TODO> - see the tests.

=head1 METHODS

=cut

sub _init
{
    my ( $self, $args ) = @_;

    my $basepath = $args->{params}->{path}
        or die "path not specified as a parameter!";
    $self->_path( File::Spec->catdir( $basepath, 'digests-cache-dir' ) );

    return;
}

=head2 $cache->get_digests({calc_cb => sub { return +{...}}})

Returns whatever calc_cb returns. A passthrough.

=cut

sub _slurp
{
    my $filename = shift;

    open my $in, '<', $filename
        or die "Cannot open '$filename' for slurping - $!";

    local $/;
    my $contents = <$in>;

    close($in);

    return $contents;
}

sub get_digests
{
    my ( $self, $args ) = @_;
    my $mtime = $args->{mtime};
    my $path  = File::Spec->catfile( $self->_path, @{ $args->{path} } );
    my $cb    = $args->{calc_cb};

    my $update = sub {
        open my $out, '>', $path;
        $out->print( JSON::MaybeXS->new( canonical => 1 )
                ->encode( +{ mtime => $mtime, digests => scalar( $cb->() ) } )
        );
        close $out;

        return;
    };
    if ( !-f $path )
    {
        make_path( dirname($path) );
        $update->();
    }
    while (1)
    {
        my $json =
            JSON::MaybeXS->new( canonical => 1 )->decode( _slurp($path) );
        if ( $json->{mtime} == $mtime )
        {
            return $json->{digests};
        }
        else
        {
            $update->();
        }
    }
    die "Bug";
}

1;    # End of File::Dir::Dumper
