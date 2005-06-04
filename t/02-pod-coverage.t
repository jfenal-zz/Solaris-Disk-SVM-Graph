#!perl
# vim: filetype=perl
BEGIN {
    eval { require Test::More; };
        print "1..0\n" and exit if $@;
        }


use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;
all_pod_coverage_ok();
