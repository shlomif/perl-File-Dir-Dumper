package File::Dir::Dumper::Stream::JSON::Writer;

use 5.014;
use strict;
use warnings;

use parent 'Format::JSON::Stream::Writer';

=head1 NAME

File::Dir::Dumper::Stream::JSON::Writer - writer for a stream of JSON data.

=head1 SYNOPSIS

    use File::Dir::Dumper::Stream::JSON::Writer ();

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

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@cpan.org> >>

=cut

1;    # End of File::Dir::Dumper
