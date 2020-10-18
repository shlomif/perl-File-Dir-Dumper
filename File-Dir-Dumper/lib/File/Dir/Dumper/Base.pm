package File::Dir::Dumper::Base;

use warnings;
use strict;

use 5.012;

=head1 NAME

File::Dir::Dumper::Base - base class for File::Dir::Dumper. B<for internal use>

=head1 METHODS

=head2 File::Dir::Dumper::Base->new()

For internal use.

=cut

sub new
{
    my $class = shift;
    my $self  = {};

    bless $self, $class;

    $self->_init(@_);

    return $self;
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT/X11 Licence.

=cut

1;    # End of File::Dir::Dumper
