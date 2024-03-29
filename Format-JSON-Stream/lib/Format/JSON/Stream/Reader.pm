package Format::JSON::Stream::Reader;

use strict;
use warnings;
use 5.014;

sub new
{
    my $class = shift;

    my $self = bless {}, $class;

    $self->_init(@_);

    return $self;
}

use Carp ();

use JSON::MaybeXS qw(decode_json);
use Class::XSAccessor accessors => { _in => 'in' };

=head1 NAME

Format::JSON::Stream::Reader - reader for stream of JSON objects.

=head1 SYNOPSIS

    use Format::JSON::Stream::Reader ();

    my $reader = Format::JSON::Stream::Reader->new(
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

    $self->_in( $args->{input} );

    $self->_init_stream();

    return;
}

sub _readline
{
    my $self = shift;

    return readline( $self->_in() );
}

sub _eof
{
    my $self = shift;

    return eof( $self->_in() );
}

sub _init_stream
{
    my $self = shift;

    if ( $self->_readline() ne "# JSON Stream by Shlomif - Version 0.2.0\n" )
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

    if ( $self->_eof() )
    {
        return;
    }

LINES:
    while ( !$self->_eof() )
    {
        $line = $self->_readline();
        if ( $line eq "--/f\n" )
        {
            return decode_json($buffer);
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

=cut

1;    # End of File::Dir::Dumper
