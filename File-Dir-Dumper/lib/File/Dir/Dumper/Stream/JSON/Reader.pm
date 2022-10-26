package File::Dir::Dumper::Stream::JSON::Reader;

use 5.014;
use strict;
use warnings;

use parent 'Format::JSON::Stream::Reader';

=head1 NAME

File::Dir::Dumper::Stream::JSON::Reader - reader for stream of JSON objects.

=head1 SYNOPSIS

    use File::Dir::Dumper::Stream::JSON::Reader ();

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

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@cpan.org> >>

=cut

1;    # End of File::Dir::Dumper
