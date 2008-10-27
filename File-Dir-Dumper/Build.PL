use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'File::Dir::Dumper',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/File/Dir/Dumper.pm',
    requires => {
        'Class::Accessor' => 0,
        'File::Find::Object' => '0.1.2',
        'JSON' => 0,
    },
    build_requires => {
        'Test::More' => 0,
        'IO::Scalar' => 0,
    },
    add_to_cleanup      => [ 'File-Dir-Dumper-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
