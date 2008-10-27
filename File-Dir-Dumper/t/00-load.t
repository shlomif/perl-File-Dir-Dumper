#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'File::Dir::Dumper' );
}

diag( "Testing File::Dir::Dumper $File::Dir::Dumper::VERSION, Perl $], $^X" );
