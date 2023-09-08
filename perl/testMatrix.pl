#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";
use Matrix;

print "\n"; ####################################################################

# Multiply two matrices.

my $A = Matrix::zeros(4, 3);
for (my $i = 0; $i < $A->numRows(); $i++) {
    for (my $j = 0; $j < $A->numCols(); $j++) {
        $A->set($i, $j, $i + $j);
    }
}
my $AA = $A->copy();
print "\$AA = \n";
$AA->disp();

print "\n";

my $B = Matrix::new([[9,8,7,6,5], [4,3,2,1,0], [-1,-2,-3,-4,-5]]);
print "\$B = \n";
$B->disp();

print "\n";

my $C = $A->dot($B);
print "\$A->dot(\$B) = \n";
$C->disp();

print "\n"; ####################################################################

# DotMultiply and plus

my $x = Matrix::new([[1,2,3], [4,5,6]]);
print "\$x = \n";
$x->disp();

print "\n";

my $y = Matrix::new([[6,5,4], [3,2,1]]);
print "\$y = \n";
$y->disp();

print "\n";

my $z = $x->dotTimes($y);
print "\$x->dotTimes(\$y) = \n";
$z->disp();

print "\n";

my $u = Matrix::new([[1], [2], [3]]);
print "\$u = \n";
$u->disp();

print "\n";

my $v = Matrix::new([[3], [2], [1]]);
print "\$v = \n";
$v->disp();

print "\n";

my $w = $u->plus($v);
print "\$u->plus(\$v) = \n";
$w->disp();

print "\n"; ####################################################################

# Solve a linear system Ax = b for x.

$A = Matrix::new([[1,1,2], [2,3,-1], [3,5,9]]);
print "\$A = \n";
$A->disp();

print "\n";

my $b = Matrix::new([[0], [1], [-2]]);
print "\$b = \n";
$b->disp();

print "\n";

$x = $A->solve($b);
print "\$A->solve(\$b) = \n";
$x->disp();

print "\n";

my $prod = $A->dot($x);
print "\$A->dot(\$x) = \n";
$prod->disp();

print "\n"; ####################################################################

# Solve AX = B where X and B are matrices, not just column vectors.

my $I = Matrix::eye(3);
print "\$I = \n";
$I->disp();

print "\n";

$B = Matrix::new([[4,0,3], [-2,1,9], [8,-2,-1]]);
print "\$B = \n";
$B->disp();

print "\n";

my $X = $A->solve($I);
print "\$A->solve(\$I) = \n";
$X->disp();

print "\n";

$prod = $A->dot($X);
print "\$A->dot(\$X) = \n";
$prod->disp();
