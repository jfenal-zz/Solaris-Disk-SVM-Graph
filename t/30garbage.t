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

plan tests => 5;

my $svmg = Solaris::Disk::SVM::Graph->new( format => 'not a format', sourcedir => 't/data' );

my $cwd = cwd;
my $tmpdir = mkdtemp( "tmpdirXXXXXX" );
chdir $tmpdir;

# output : output format object
$svmg->output(rubbish=>);
ok(-f 'svm.png', "default output image generated");
$ENV{IMAGEVIEWER} and system "$ENV{IMAGEVIEWER} svm.png";
unlink 'svm.png';

$svmg->output( format => 'png');
ok(-f 'svm.png.png', "default output image generated with specified format");
$ENV{IMAGEVIEWER} and system "$ENV{IMAGEVIEWER} svm.png.png";
unlink 'svm.png.png';

$svmg->output( format => 'notaformat');
ok(-f 'svm.png', "default output image generated with thrashed format");
$ENV{IMAGEVIEWER} and system "$ENV{IMAGEVIEWER} svm.png";
unlink 'svm.png';

$svmg->output( output => 'image', format => 'svg' );
ok(-f 'image.svg', "output image generated with accepted format");
$ENV{IMAGEVIEWER} and system "$ENV{IMAGEVIEWER} image.svg";
unlink 'image.svg';

my $rc = $svmg->output( output => 'image.not' );
ok(! defined $rc, "output image generated with not allowed implied format");

# output : output format object
#$svmg->output( output => 'ymmv.png' );
#ok(-f 'ymmv.png', "default output image generated");
#$file = `file ymmv.png`;
#like($file, qr(PNG image data), "file tells us ymmv.png is PNG");

chdir $cwd;
rmdir $tmpdir;
