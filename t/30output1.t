#!/usr/bin/perl -w
# vim: filetype=perl
BEGIN {
        eval { require Test::More; };
            print "1..0\n" and exit if $@;
        }

use strict;
use Cwd;
use Test::More;
use lib qw(lib ../lib);
use Solaris::Disk::SVM::Graph;
use File::Temp qw( :mktemp );

plan tests => 4;

my $svmg = Solaris::Disk::SVM::Graph->new( sourcedir => 't/data' );

my $cwd = cwd;
my $tmpdir = mkdtemp( "tmpdirXXXXXX" );
chdir $tmpdir;

# output : output format object
$svmg->output();
ok(-f 'svm.png', "default output image generated");
my $file = `file svm.png`;
like($file, qr(PNG image data), "file tells us svm.png is PNG");
$ENV{IMAGEVIEWER} and system "$ENV{IMAGEVIEWER} svm.png";


# output : output format object
$svmg->output( output => 'ymmv.png' );
ok(-f 'ymmv.png', "default output image generated");
$file = `file ymmv.png`;
like($file, qr(PNG image data), "file tells us ymmv.png is PNG");
$ENV{IMAGEVIEWER} and system "$ENV{IMAGEVIEWER} ymmv.png";

unlink 'svm.png';
unlink 'ymmv.png';
chdir $cwd;
rmdir $tmpdir;
