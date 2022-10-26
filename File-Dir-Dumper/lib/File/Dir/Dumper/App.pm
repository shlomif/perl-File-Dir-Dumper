package File::Dir::Dumper::App;

use warnings;
use strict;

use 5.012;

use parent 'File::Dir::Dumper::Base';

use Getopt::Long qw(GetOptionsFromArray);
use Pod::Usage   qw( pod2usage );

use File::Dir::Dumper::Scanner   ();
use Format::JSON::Stream::Writer ();

use Class::XSAccessor accessors => {
    _digest_cache        => '_digest_cache',
    _digest_cache_params => '_digest_cache_params',
    _digests             => '_digests',
    _out_to_stdout       => '_out_to_stdout',
    _out_filename        => '_out_filename',
    _dir_to_dump         => '_dir_to_dump',
};

=head1 NAME

File::Dir::Dumper::App - a command line app-implemented as a class to do the
dumping.

=head1 SYNOPSIS

    use File::Dir::Dumper::App;

    my $app = File::Dir::Dumper::App->new({argv => \@ARGV});

    exit($app->run());

=head1 METHODS

=head2 $self->new({ argv => \@ARGV})

Scans using the @ARGV command line arguments.

=head2 $self->run()

Runs the application.

=cut

sub _init
{
    my $self = shift;
    my $args = shift;

    my $argv = $args->{'argv'};

    my $output_dest;
    my @digests;
    my ( $help, $man );
    my $digest_cache = 'Dummy';
    my %cache_params;

    GetOptionsFromArray(
        $argv,
        'digest-cache=s'       => \$digest_cache,
        'digest-cache-param=s' => \%cache_params,
        "digest=s"             => \@digests,
        "output|o=s"           => \$output_dest,
        'help|h'               => \$help,
        'man'                  => \$man,
    ) or die "parsing options failed - $!";

    pod2usage(1)                                 if $help;
    pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

    my $dir_to_dump = shift(@$argv);

    if ( defined($output_dest) )
    {
        $self->_out_to_stdout(0);
        $self->_out_filename($output_dest);
    }
    else
    {
        $self->_out_to_stdout(1);
    }
    $self->_digests( \@digests );
    $self->_dir_to_dump($dir_to_dump);
    $self->_digest_cache($digest_cache);
    $self->_digest_cache_params( \%cache_params );

    return;
}

sub run
{
    my $self = shift;

    my $out;
    if ( $self->_out_to_stdout() )
    {
        open $out, ">&STDOUT";
    }
    else
    {
        open $out, ">", $self->_out_filename();
    }

    my $digests = $self->_digests;

    my $scanner = File::Dir::Dumper::Scanner->new(
        {
            dir => $self->_dir_to_dump(),
            ( ( @$digests ? ( digests => $digests ) : () ), ),
            digest_cache        => $self->_digest_cache,
            digest_cache_params => $self->_digest_cache_params,
        }
    );
    my $writer = Format::JSON::Stream::Writer->new(
        {
            output => $out,
        }
    );

    while ( defined( my $token = $scanner->fetch() ) )
    {
        $writer->put($token);
    }

    $writer->close();

    return 0;
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@cpan.org> >>

=cut

1;    # End of File::Dir::Dumper
