#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use IO::String;

# use File::Dir::Dumper::Stream::JSON::Writer;
use File::Dir::Dumper::Stream::JSON::Reader;

{
    my $buffer = <<"EOF";
# JSON Stream by Shlomif - Version 0.2.0
{"want":"me"}
--/f
{"want":"you"}
--/f
EOF

    my $in = IO::String->new($buffer);
    my $reader = File::Dir::Dumper::Stream::JSON::Reader->new(
        {
            input => $in,
        }
    );

    # TEST
    ok ($reader, "Reader was initialised");

    # TEST
    is_deeply($reader->fetch(),
        {want => "me",},
        "->fetch() works for first token",
    );

    # TEST
    is_deeply($reader->fetch(),
        {want => "you",},
        "->fetch works for second token",
    );

    # TEST
    ok(!defined($reader->fetch), "No more tokens");
}

