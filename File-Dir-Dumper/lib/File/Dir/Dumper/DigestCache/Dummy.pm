package File::Dir::Dumper::DigestCache::Dummy;

use warnings;
use strict;

use parent 'File::Dir::Dumper::Base';

use 5.012;

=head1 NAME

File::Dir::Dumper::DigestCache::Dummy - pass through digest cache for
L<File::Dir::Dumper> .

=head1 SYNOPSIS

B<TODO> - see the tests.

=head1 METHODS

=cut

sub _init
{
    my ($self, $args) = @_;

    return;
}

=head2 $cache->get_digests({calc_cb => sub { return +{...}}})

Returns whatever calc_cb returns. A passthrough.

=cut

sub get_digests
{
    my ($self, $args) = @_;

    return $args->{calc_cb}->();
}

1; # End of File::Dir::Dumper
