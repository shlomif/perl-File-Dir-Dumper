#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 49;

use POSIX qw(mktime strftime);
use File::Path;
use English qw( -no_match_vars );

use Devel::CheckOS qw(:booleans);

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "t", "lib");

use File::Find::Object::TreeCreate;

use File::Dir::Dumper::Scanner;


{
    my $tree =
    {
        'name' => "traverse-1/",
        'subs' =>
        [
            {
                'name' => "a.doc",
                'contents' => "This file was spotted in the wild.",
            },
            {
                'name' => "b/",
            },
            {
                'name' => "foo/",
                'subs' =>
                [
                    {
                        'name' => "yet/",
                    },
                ],
            },
        ],
    };

    my $t = File::Find::Object::TreeCreate->new();
    $t->create_tree("./t/sample-data/", $tree);

    my $test_dir = "t/sample-data/traverse-1";

    my $a_doc_time = mktime(1, 2, 3, 4, 5, 106);
    utime($a_doc_time, $a_doc_time, $t->get_path("$test_dir/a.doc"));

    my $scanner = File::Dir::Dumper::Scanner->new(
        {
            dir => $t->get_path($test_dir),
        }
    );

    my $token;

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "header", "Token is of type header");

    # TEST
    is ($token->{dir_to_dump}, $t->get_path($test_dir),
        "dir_to_dump is OK."
    );

    # TEST
    is ($token->{stream_type}, "Directory Dump",
        "stream_type is OK."
    );

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "dir", "type is dir");

    # TEST
    is ($token->{depth}, 0, "depth is 0");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "file", "Type is file");

    # TEST
    is ($token->{filename}, "a.doc", "Filename is OK.");

    # TEST
    is ($token->{mtime},
        strftime("%Y-%m-%dT%H:%M:%S", localtime($a_doc_time)),
        "mtime is OK.",
    );

    # TEST
    is ($token->{size},
        length("This file was spotted in the wild."),
        "size is OK.",
    );

    # TEST
    is ($token->{perms},
        sprintf("%04o", ((stat($t->get_path("$test_dir/a.doc")))[2]&07777)),
        "perms are OK."
    );

    # TEST
    is ($token->{user},
        File::Dir::Dumper::Scanner::_my_getpwuid($UID),
        "user is OK."
    );

    # TEST
    is ($token->{group},
        (
            os_is('Unix')
            ? scalar(getgrgid((stat($t->get_path("$test_dir/a.doc")))[5]))
            : "unknown"
        ),
        "group is OK."
    );

    # TEST
    is ($token->{depth}, 1, "Token depth is 1");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "dir", "Token is dir");

    # TEST
    is ($token->{depth}, 1, "Token depth is 1");

    # TEST
    is ($token->{filename}, "b", "dir name is 'b'");

    # TEST
    is ($token->{perms},
        sprintf("%04o", ((stat($t->get_path("$test_dir/b/")))[2]&07777)),
        "perms are OK."
    );

    # TEST
    is ($token->{user},
        File::Dir::Dumper::Scanner::_my_getpwuid($UID),
        "user is OK."
    );

    # TEST
    is ($token->{group},
        (
            os_is('Unix')
            ? scalar(getgrgid((stat($t->get_path("$test_dir/b/")))[5]))
            : "unknown"
        ),
        "group is OK."
    );

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "updir", "Token is updir");

    # TEST
    is ($token->{depth}, 1, "updir token (from 'b') has depth 1");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "dir", "Token is dir");

    # TEST
    is ($token->{filename}, "foo", "dir name is 'foo'");

    # TEST
    is ($token->{depth}, 1, "Token depth is 1");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "dir", "Token is dir");

    # TEST
    is ($token->{filename}, "yet", "dir name is 'yet'");

    # TEST
    is ($token->{depth}, 2, "Token depth is 2");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "updir", "Token is updir");

    # TEST
    is ($token->{depth}, 2, "Token depth is 2");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "updir", "Token is updir");

    # TEST
    is ($token->{depth}, 1, "Token depth is 1");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "updir", "Token is updir");

    # TEST
    is ($token->{depth}, 0, "Token depth is 0");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "footer", "Token is footer");

    $token = $scanner->fetch();

    # TEST
    ok (!defined($token), "Token is undefined - reached end.");

    $token = $scanner->fetch();

    # TEST
    ok (!defined($token), "Token is undefined - make sure we don't restart");

    rmtree($t->get_path($test_dir))
}

{
    my $tree =
    {
        'name' => "traverse-1/",
        'subs' =>
        [
            {
                'name' => "a.doc",
                'contents' => "This file was spotted in the wild.",
            },
            {
                'name' => "cat.txt",
                'contents' => "Meow Meow\n",
            },
            {
                'name' => "foo/",
                'subs' =>
                [
                    {
                        'name' => "yet/",
                    },
                ],
            },
        ],
    };

    my $t = File::Find::Object::TreeCreate->new();
    $t->create_tree("./t/sample-data/", $tree);

    my $test_dir = "t/sample-data/traverse-1";

    my $a_doc_time = mktime(1, 2, 3, 4, 5, 106);
    utime($a_doc_time, $a_doc_time, $t->get_path("$test_dir/a.doc"));

    my $scanner = File::Dir::Dumper::Scanner->new(
        {
            dir => $t->get_path($test_dir),
            digests => [qw(SHA-512 MD5)],
        }
    );

    my $token;

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "header", "Token is of type header");

    # TEST
    is ($token->{dir_to_dump}, $t->get_path($test_dir),
        "dir_to_dump is OK."
    );

    # TEST
    is ($token->{stream_type}, "Directory Dump",
        "stream_type is OK."
    );

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "dir", "type is dir");

    # TEST
    is ($token->{depth}, 0, "depth is 0");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "file", "Type is file");

    # TEST
    is ($token->{filename}, "a.doc", "Filename is OK.");

    # TEST
    is_deeply (
        $token->{digests},
        +{
            MD5 => '85878a491ed9a0e0164c5ee398a6ac74',
            'SHA-512' => 'de8e52b8e38dbd7072e1e73b8340bf357d5af4058fd0110132cb45a532e9506f366f0df4b221a889717304830954d6d53cded53020d465044da7547a87ed02ce',
        },
        "a.doc digests."
    );

    # TEST
    is ($token->{depth}, 1, "Token depth is 1");

    $token = $scanner->fetch();

    # TEST
    is ($token->{type}, "file", "Type is file");

    # TEST
    is ($token->{filename}, "cat.txt", "Filename is OK.");

    # TEST
    is_deeply (
        $token->{digests},
        +{
            MD5 => '2aa48e4588adb2357dd9c5ac4ef1c191',
            'SHA-512' => '265702ac97739a435322d2b6f4caec983e3f370056c75fe03c9226aad31479b92ed8b4a4dfe2137dbbe5039b27c9f39a7f25b8957a9ddb8d849ff8c01e1fcaac',
        },
        "cat.txt digests."
    );

    # TEST
    is ($token->{depth}, 1, "Token depth is 1");

    rmtree($t->get_path($test_dir))
}
