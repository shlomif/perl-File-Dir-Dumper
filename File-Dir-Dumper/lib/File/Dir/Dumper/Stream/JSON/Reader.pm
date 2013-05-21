package File::Dir::Dumper::Stream::JSON::Reader;

use warnings;
use strict;

use base 'File::Dir::Dumper::Base';

use Carp;

use JSON;

__PACKAGE__->mk_accessors(qw(_in));

=head1 NAME

File::Dir::Dumper::Stream::JSON::Reader - reader for stream of JSON objects.

=head1 VERSION

Version 0.0.8

=cut

our $VERSION = '0.0.8';

=head1 SYNOPSIS

    use File::Dir::Dumper::Stream::JSON::Reader;

    my $reader = File::Dir::Dumper::Stream::JSON::Reader->new(
        {
            input => \*FILEHANDLE,
        }
    );

    while (defined(my $token = $reader->fetch())
    {
        # Do something with $token.
    }

=head1 METHODS

=head2 $self->new({ input => $in_filehandle})

Initializes a new object that reads from the filehandle $in_filehandle.

=head2 $self->fetch()

Fetches the next object. Returns undef upon end of file.

=cut

sub _init
{
    my $self = shift;
    my $args = shift;

    $self->_in($args->{input});

    $self->_init_stream();

    return;
}

sub _readline
{
    my $self = shift;

    return readline($self->_in());
}

sub _eof
{
    my $self = shift;

    return eof($self->_in());
}

sub _init_stream
{
    my $self = shift;

    if ($self->_readline() ne "# JSON Stream by Shlomif - Version 0.2.0\n")
    {
        Carp::confess "No header for JSON stream";
    }

    return;
}

sub fetch
{
    my $self = shift;

    my $buffer = "";
    my $line;

    if ($self->_eof())
    {
        return;
    }

    LINES:
    while (!$self->_eof())
    {
        $line = $self->_readline();
        if ($line eq "--/f\n")
        {
            return from_json($buffer);
        }
        else
        {
            $buffer .= $line;
        }
    }
    Carp::confess "Error! Reached end of file without record terminator.";
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
