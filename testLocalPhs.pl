#!/usr/bin/perl

use strict;
use warnings;

use lib ".";
use LocalPhs;

my $rbfExponent = 3;
my $polyDegree = 1;

# Define spatial domain [a,b] x [c,d], with m rows and n columns.
my $a = -1;  my $b = 1;  my $n = 5;
my $c = -1;  my $d = 1;  my $m = 5;

# Define number of rows (M) and columns (N) for evaluation points.
my $M = 12;
my $N = 12;

# Define the size of the stencil.
my $stencilRadius = 1;

################################################################################

my ($x, $y, $xx, $yy, $nodes, $zz);
eval {
    $x = Matrix::linspace($a, $b, $n);
    $y = Matrix::linspace($c, $d, $m);
    ($xx, $yy) = Matrix::meshgrid($x, $y);
    $xx = $xx->flatten;  $yy = $yy->flatten;
    $nodes = $xx->vstack($yy)->transpose;
    $zz = Phs::testFunc2d($nodes);
};
die if $@;

my ($X, $Y, $XX, $YY, $NODES, $ZZ);
eval {
    $X = Matrix::linspace($a, $b, $N);
    $Y = Matrix::linspace($c, $d, $M);
    ($XX, $YY) = Matrix::meshgrid($X, $Y);
    $XX = $XX->flatten;  $YY = $YY->flatten;
    $NODES = $XX->vstack($YY)->transpose;
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
    print "\$estimate = \n";
    $estimate->transpose->disp;
    print "\n";
    print "\$ZZ = \n";
    $ZZ->transpose->disp;
    print "\n";
    $diff = $estimate->plus($ZZ->dot(-1));
    print "\$diff = \n";
    $diff->transpose->disp;
};
die if $@;
