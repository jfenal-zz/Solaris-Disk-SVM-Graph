#!/usr/bin/perl -w
# vim: filetype=perl
BEGIN {
        eval { require Test::More; };
            print "1..0\n" and exit if $@;
        }

use strict;
use Test::More;
use lib qw(lib ../lib);
use Solaris::Disk::SVM::Graph;

plan tests => 16;

my $svmg = Solaris::Disk::SVM::Graph->new( sourcedir => 't/data' );

isa_ok($svmg, 'Solaris::Disk::SVM::Graph', 'isa_ok');

# default values
is($svmg->fontname, 'helvetica', 'default font face via AUTOLOAD');
is($svmg->fontsize, 9, 'default font size via AUTOLOAD');
is($svmg->format, 'png', 'default format via AUTOLOAD');
is($svmg->orientation, 0, 'default orientation via AUTOLOAD');

# 6
$svmg->fontname('times');
is($svmg->fontname, 'times', 'New font name set by AUTOLOAD');

# 7
$svmg->fontsize(10);
is($svmg->fontsize, 10, 'New font size set by AUTOLOAD');

# 8
$svmg->format('PNG');
is($svmg->format, 'png', 'New format set by AUTOLOAD');

# 9
$svmg->orientation( 'true' );
is($svmg->orientation, 1, 'New orientation set by AUTOLOAD');

# 10
$svmg->orientation( 1 );
is($svmg->orientation, 1, 'New orientation set by AUTOLOAD');

# 11
$svmg->orientation( 0 );
is($svmg->orientation, 0, 'New orientation set by AUTOLOAD');

# 12
$svmg->format('WBMP');
is($svmg->format, 'wbmp', 'New format set by AUTOLOAD');

# 13
$svmg->format('GiF');
is($svmg->format, 'gif', 'New format set by AUTOLOAD');

# 14
$svmg->width(1000);
is($svmg->width, 1000, 'New xsize set by AUTOLOAD');

# 15
$svmg->height(999);
is($svmg->height, 999, 'New ysize set by AUTOLOAD');

# 16
my $ret= eval { $svmg->ker_sploosh(1); };
like($@, qr/invalid accessor/, 'unknown method name by AUTOLOAD');

# 
