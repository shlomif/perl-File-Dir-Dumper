package File::Dir::Dumper::Stream::JSON::Writer;

use warnings;
use strict;

use 5.012;

use parent 'File::Dir::Dumper::Base';

use Carp;

use JSON::MaybeXS ();

__PACKAGE__->mk_accessors(qw(_out));

=head1 NAME

File::Dir::Dumper::Stream::JSON::Writer - writer for a stream of JSON data.

=head1 VERSION

Version 0.0.10

=cut

our $VERSION = '0.0.10';

=head1 SYNOPSIS

    use File::Dir::Dumper::Stream::JSON::Writer;

    my $writer = File::Dir::Dumper::Stream::JSON::Writer->new(
        {
            output => $output_file_handle,
        }
    );

    $writer->put($token);

    $writer->put($another_token);

    .
    .
    .

    $writer->close();

=head1 METHODS

=head2 $self->new({ output => $output_filehandle})

Initializes a new object that writes to the filehandle $output_filehandle.

=head2 $self->put($token)

Outputs the next token as serialized.

=head2 $self->close()

Closes the output filehandle.

=cut

sub _init
{
    my $self = shift;
    my $args = shift;

    $self->_out($args->{output});

    $self->_init_stream();

    return;
}

sub _print
{
    my $self = shift;
    my $line = shift;

    print {$self->_out()} $line, "\n";
}

sub _init_stream
{
    my $self = shift;

    $self->_print("# JSON Stream by Shlomif - Version 0.2.0");

    return;
}

sub put
{
    my $self = shift;
    my $token = shift;

    $self->_print(JSON::MaybeXS->new(canonical => 1)->encode($token));
    $self->_print("--/f");

    return;
}

sub close
{
    my $self = shift;

    return close($self->_out());
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
