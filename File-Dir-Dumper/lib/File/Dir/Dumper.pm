package File::Dir::Dumper;

use warnings;
use strict;

=head1 NAME

File::Dir::Dumper - dump directory structures' meta-data in a consistent and 
machine-readable way.

=head1 VERSION

Version 0.0.3

=cut

our $VERSION = '0.0.3';

=head1 SYNOPSIS

    use File::Dir::Dumper;

    my $dumper = File::Dir::Dumper->new(
        {
            output_to => \*STDOUT,
            source => "/path/to/dir/to/dump",
        }
    );

=head1 METHODS

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
