#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use File::Dir::Dumper::DigestCache::Dummy;

{
    my $obj = File::Dir::Dumper::DigestCache::Dummy->new(
        {
            params =>
            {
                path => "./foo",
            },
        }
    );

    # TEST
    ok ($obj, 'Object was initialized');
}
