#!/usr/bin/perl

use strict;
use warnings;

use lib ".";
use LocalPhs;

my $dims = 2;                                                       # dimensions
my $rbfExponent = 3;                 # odd number exponent to use in the phs rbf
my $polyDegree = 1;                     # maximum polynomial degree in the basis
my $a = -1;  my $b = 1;                                   # bounds on the domain
my $n = 100;                                                   # number of nodes
my $N = 1000;                                      # number of evaluation points
my $stencilRadius = 5/8;    # how far away to look for neighbors of a given node

################################################################################

my ($nodes, $zz);
eval {
    $nodes = Matrix::rand($n, $dims);
    $nodes = $nodes->dot($b - $a)->plus($a);
    $zz = Phs::testFunc2d($nodes);
};
die if $@;

my ($NODES, $ZZ);
eval {
    $NODES = Matrix::rand($N, $dims);
    $NODES = $NODES->dot($b - $a)->plus($a);
    $ZZ = Phs::testFunc2d($NODES);
};
die if $@;

my ($phs, $estimate);
eval {
    $phs = LocalPhs::new($rbfExponent, $polyDegree, $nodes, $zz, $stencilRadius);
    $estimate = $phs->evaluate($NODES);
};
die if $@;

my $diff;
eval {
    $diff = $estimate->minus($ZZ);
    print "average error = " . $diff->norm(1) / $diff->len . "\n";
};
die if $@;
