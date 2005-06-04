#!perl -T
# vim: filetype=perl
BEGIN {
    eval { require Test::More; };
        print "1..0\n" and exit if $@;
        }


use Test::More;
eval "use Test::Pod 1.14";
plan skip_all => "Test::Pod 1.14 required for testing POD" if $@;
all_pod_files_ok();
