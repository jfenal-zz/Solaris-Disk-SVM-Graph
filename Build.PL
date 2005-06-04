use Module::Build;
my $build = Module::Build->new(
    module_name  => 'Solaris::Disk::SVM::Graph',
    script_files => 'script/svmgraph',
    version_from => 'lib/Solaris/Disk/SVM.pm',
    license      => 'perl',
    requires     => {
        GraphViz             => '1.99',
        'Solaris::Disk::SVM' => '0',
    },
    recommends     => {
        'Paper::Specs'       => '0.06',
    },
    add_to_cleanup     => [ '*~', '*/*~', '*/*/*/*~' ],
    gzip               => 'gzip -9f',
    create_makefile_pl => 'traditional',

    #    recommends => { 'Test::More' => '0', },
);
$build->create_build_script;
