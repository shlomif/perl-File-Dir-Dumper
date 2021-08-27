package File::Dir::Dumper;

use warnings;
use strict;

use 5.012;

sub AUTLOAD
{
    die "This is a stub module.";
}

=head1 NAME

File::Dir::Dumper - dump directory structures' meta-data in a consistent and
machine-readable way.

=head1 SYNOPSIS

This is a stub module.

B<DO NOTE USE DIRECTLY!>

See L<dir-dump> .

=head1 METHODS

=head2 AUTLOAD

die on use.

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@cpan.org> >>

=head1 SEE ALSO

L<File::Find::Object>

L<http://code.google.com/p/xml-dir-listing/> and
L<http://dir2xml.sourceforge.net/> are two projects that provide similar
functionality while utilising XML and Java instead of JSON and Perl.

=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT/X11 Licence.

=cut

1;    # End of File::Dir::Dumper
