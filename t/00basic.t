# vim: filetype=perl
# in case Test::More ain't there
BEGIN {
    eval { require Test::More; };
    print "1..0\n" and exit if $@;
}

use strict;
use Test::More;

plan tests => 1;

ok(defined(-x 'script/svmgraph'), 'svmgraph has the x bit' );
