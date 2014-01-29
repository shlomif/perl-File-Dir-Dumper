package File::Dir::Dumper::App;

use warnings;
use strict;

use 5.012;

use parent 'File::Dir::Dumper::Base';

use Carp;

use Getopt::Long qw(GetOptionsFromArray);
use Pod::Usage;

use File::Dir::Dumper::Scanner;
use File::Dir::Dumper::Stream::JSON::Writer;

__PACKAGE__->mk_accessors(
    qw(
    _out_to_stdout
    _out_filename
    _dir_to_dump
    )
);

=head1 NAME

File::Dir::Dumper::App - a command line app-implemented as a class to do the
dumping.

=head1 VERSION

Version 0.0.9

=cut

our $VERSION = '0.0.9';

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

    my ($help, $man);

    GetOptionsFromArray($argv,
        "output|o=s" => \$output_dest,
        'help|h' => \$help,
        'man' => \$man,
    );

    pod2usage(1) if $help;
    pod2usage(-exitstatus => 0, -verbose => 2) if $man;

    my $dir_to_dump = shift(@$argv);

    if (defined($output_dest))
    {
        $self->_out_to_stdout(0);
        $self->_out_filename($output_dest);
    }
    else
    {
        $self->_out_to_stdout(1);
    }

    $self->_dir_to_dump($dir_to_dump);

    return;
}

sub run
{
    my $self = shift;

    my $out;
    if ($self->_out_to_stdout())
    {
        open $out, ">&STDOUT";
    }
    else
    {
        open $out, ">", $self->_out_filename();
    }

    my $scanner = File::Dir::Dumper::Scanner->new(
        {
            dir => $self->_dir_to_dump(),
        }
    );
    my $writer = File::Dir::Dumper::Stream::JSON::Writer->new(
        {
            output => $out,
        }
    );

    while (defined(my $token = $scanner->fetch()))
    {
        $writer->put($token);
    }

    $writer->close();

    return 0;
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-file-dir-dumper at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Dir-Dumper>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc File::Dir::Dumper


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-Dir-Dumper>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/File-Dir-Dumper>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/File-Dir-Dumper>

=item * Search CPAN

L<http://search.cpan.org/dist/File-Dir-Dumper>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT/X11 Licence.

=cut

1; # End of File::Dir::Dumper
