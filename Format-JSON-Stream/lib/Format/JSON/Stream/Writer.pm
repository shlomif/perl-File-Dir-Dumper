package Format::JSON::Stream::Writer;

use warnings;
use strict;

use 5.012;

use parent 'File::Dir::Dumper::Base';

use Carp ();

use JSON::MaybeXS ();
use Class::XSAccessor accessors => { _out => '_out' };

=head1 NAME

Format::JSON::Stream::Writer - writer for a stream of JSON data.

=head1 SYNOPSIS

    use Format::JSON::Stream::Writer ();

    my $writer = Format::JSON::Stream::Writer->new(
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

    $self->_out( $args->{output} );

    $self->_init_stream();

    return;
}

sub _print
{
    my $self = shift;
    my $line = shift;

    print { $self->_out() } $line, "\n";
}

sub _init_stream
{
    my $self = shift;

    $self->_print("# JSON Stream by Shlomif - Version 0.2.0");

    return;
}

sub put
{
    my $self  = shift;
    my $token = shift;

    $self->_print( JSON::MaybeXS->new( canonical => 1 )->encode($token) );
    $self->_print("--/f");

    return;
}

sub close
{
    my $self = shift;

    return close( $self->_out() );
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@cpan.org> >>

=cut

1;    # End of File::Dir::Dumper
