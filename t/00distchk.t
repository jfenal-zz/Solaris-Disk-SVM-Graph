# vim: filetype=perl
BEGIN {
    eval { require Test::More; };
        print "1..0\n" and exit if $@;
        }

use strict;
use Test::More;
eval "use Test::Distribution";
plan skip_all => "Test::Distribution required for checking distribution" if $@;

