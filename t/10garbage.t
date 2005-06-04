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

plan tests => 2;

TEST1: {
    my $svmg = Solaris::Disk::SVM::Graph->new(
        sourcedir => 't/data',
        claptrap  => 'mess',
        wish_wash =>
    );

    isa_ok( $svmg, 'Solaris::Disk::SVM::Graph', 'isa_ok' );
}

TEST2: {
    my $svmg = Solaris::Disk::SVM::Graph->new;

    isa_ok( $svmg, 'Solaris::Disk::SVM::Graph', 'isa_ok' );
}
