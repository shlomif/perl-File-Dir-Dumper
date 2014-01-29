use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'File::Dir::Dumper',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/File/Dir/Dumper.pm',
    requires => {
        'Class::Accessor' => 0,
        'Carp' => 0,
        'Devel::CheckOS' => 0,
        'File::Find::Object' => '0.1.2',
        'Getopt::Long' => '2.36',
        'JSON' => 0,
        'List::Util' => 0,
        'parent' => 0,
        'POSIX' => 0,
        'perl' => '5.012',
        'strict' => 0,
        'warnings' => 0,
    },
    build_requires => {
        'Devel::CheckOS' => 0,
        'IO::String' => 0,
        'Test::More' => 0,
    },
    configure_requires => {
        'Module::Build' => '0.36',
    },
    add_to_cleanup      => [ 'File-Dir-Dumper-*' ],
    script_files => ["scripts/dir-dump",],
    meta_merge =>
    {
        resources =>
        {
            repository => "http://bitbucket.org/shlomif/perl-file-dir-dumper",
            homepage => "http://www.shlomifish.org/open-source/projects/File-Dir-Dumper/",
        },
        keywords =>
        [
            "depth",
            "dir",
            "directory",
            "dumper",
            "file",
            "filename",
            "group",
            "json",
            "length",
            "meta-data",
            "mtime",
            "permissions",
            "pure-perl",
            "size",
            "stream",
            "traverse",
            "tree",
            "user",
        ],
    },
);

$builder->create_build_script();
