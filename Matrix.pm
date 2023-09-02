#!/usr/bin/perl

package Matrix;

# Methods and functions for creating and manipulating Matrix objects.
# Greg Barnett
# August 2023

use strict;
use warnings;

################################################################################

# CONSTRUCTORS

sub new {
    # Create new matrix from a 2D array of values.
    my ($items, $numRows, $numCols);
    
    if (scalar @_ == 1 && ref $_[0]) {
        $items = shift;
        $numRows = scalar @{$items};
        $numCols = scalar @{@{$items}[0]};
    } else {
        die "Bad input for new matrix.  Give ref to array.";
    }
    
    my $self = ["Matrix", $items, $numRows, $numCols];
    bless $self;
    return $self;
}



sub zeros {
    # New matrix of zeros.
    die "Matrix::zeros() requires two inputs, numRows and numCols.    " if scalar @_ != 2;
    my ($numRows, $numCols) = @_;
    
    my @items = ();
    
    for (my $i = 0; $i < $numRows; $i++) {
        my @tmp = ();
        for (my $j = 0; $j < $numCols; $j++) {
            push(@tmp, 0);
        }
        push(@items, \@tmp);
    }
    
    my $self = ["Matrix", \@items, $numRows, $numCols];
    bless $self;
    return $self;
}



sub ones {
    # New matrix of ones.
    die "Matrix::ones() requires two inputs, numRows and numCols.    " if scalar @_ != 2;
    my ($numRows, $numCols) = @_;
    
    my @items = ();
    
    for (my $i = 0; $i < $numRows; $i++) {
        my @tmp = ();
        for (my $j = 0; $j < $numCols; $j++) {
            push(@tmp, 1);
        }
        push(@items, \@tmp);
    }
    
    my $self = ["Matrix", \@items, $numRows, $numCols];
    bless $self;
    return $self;
}



sub eye {
    # New Identity matrix.
    die "Matrix::eye() requires one input, numRows (numCols always equals numRows).    " if scalar @_ != 1;
    my ($numRows) = @_;

    my $numCols = $numRows;
    my @items = ();
    
    for (my $i = 0; $i < $numRows; $i++) {
        my @tmp = ();
        for (my $j = 0; $j < $numCols; $j++) {
            if ($j == $i) {
                push(@tmp, 1);
            } else {
                push(@tmp, 0);
            }
        }
        push(@items, \@tmp);
    }
    
    my $self = ["Matrix", \@items, $numRows, $numCols];
    bless $self;
    return $self;
}



sub linspace {
    # New 1D matrix of equally-spaced values with known start and finish.
    die "Matrix::linspace() requires three inputs: start, finish, and number of points.    " if scalar @_ != 3;
    my ($a, $b, $numCols) = @_;
    
    my $dx = ($b - $a) / ($numCols - 1);
    my $item = $a;
    my @items = ();
    for (my $i = 0; $i < $numCols; $i++) {
        push @items, $item;
        $item += $dx;
    }
    my $numRows = 1;
    my $items = [\@items];
    
    my $self = ["Matrix", $items, $numRows, $numCols];
    bless $self;
    return $self;
}

################################################################################

# GETTERS

sub type {
    my $self = shift;
    return @{$self}[0];
}



sub items {
    die if scalar @_ != 1;
    my $self = shift;
    
    my $items = @{$self}[1];
    return $items if defined $items && ! scalar @_;
    print STDERR "\nFailed to get the items in the matrix.\n";  die;
}



sub numRows {
    die if scalar @_ != 1;
    my $self = shift;
    
    my $numRows = @{$self}[2];
    return $numRows if defined $numRows;
    print STDERR "\nFailed to get the number of rows.\n";  die;
}



sub numCols {
    die if scalar @_ != 1;
    my $self = shift;
    
    my $numCols = @{$self}[3];
    return $numCols if defined $numCols;
    print STDERR "\nFailed to get the number of columns.\n";  die;
}

################################################################################

sub meshgrid {
    my $x = shift;
    my $y = shift;
    
    my $xx = Matrix::zeros($y->numCols(), $x->numCols());
    my $yy = Matrix::zeros($y->numCols(), $x->numCols());
    
    for (my $i = 0; $i < $y->numCols(); $i++) {
        for (my $j = 0; $j < $x->numCols(); $j++) {
            $xx->set($i, $j, $x->item($j));
            $yy->set($i, $j, $y->item($i));
        }
    }
    
    return ($xx, $yy);
}



sub vstack {
    my $self = shift;
    my $other = shift;
    
    die "Dimension mismatch.    " if $self->numCols() != $other->numCols();
    
    my $out = Matrix::zeros($self->numRows() + $other->numRows(), $other->numCols());
    
    for (my $i = 0; $i < $self->numRows(); $i++) {
        for (my $j = 0; $j < $self->numCols(); $j++) {
            $out->set($i, $j, $self->item($i, $j));
        }
    }
    
    for (my $i = $self->numRows(); $i < $self->numRows() + $other->numRows(); $i++) {
        for (my $j = 0; $j < $self->numCols(); $j++) {
            $out->set($i, $j, $other->item($i - $self->numRows(), $j));
        }
    }
    
    return $out;
}



sub hstack {
    my $self = shift;
    my $other = shift;
    
    my $out;
    eval {
        $out = $self->transpose()->vstack($other->transpose());
    };
    die if $@;
    
    return $out->transpose();
}



sub flatten {
    my $self = shift;
    
    my $out = Matrix::zeros(1, $self->numRows() * $self->numCols());
    my $k = 0;
    
    for (my $i = 0; $i < $self->numRows(); $i++) {
        for (my $j = 0; $j < $self->numCols(); $j++) {
            $out->set($k, $self->item($i, $j));
            $k++;
        }
    }
    
    return $out;
}



sub disp {
    my $self = shift;
    
    foreach my $row (@{$self->items()}) {
        foreach my $item (@{$row}) {
            printf "%10.6f ", $item;
        }
        print "\n";
    }
}



sub item {
    my $self = shift;

    my ($i, $j);
    
    if (scalar @_ == 2) {
        $i = shift;
        $j = shift;
        return @{@{$self->items()}[$i]}[$j];
    } elsif (scalar @_ == 1 && $self->numRows() == 1) {
        $j = shift;
        return @{@{$self->items()}[0]}[$j];
    } elsif (scalar @_ == 1 && $self->numCols() == 1) {
        $i = shift;
        return @{@{$self->items()}[$i]}[0];
    }
}



sub row {
    my $self = shift;
    my $i = shift;
    
    my $row = @{$self->items()}[$i];
    my $out = Matrix::new([$row]);
    
    return $out;
}



sub col {
    my $self = shift;
    my $j = shift;

    return $self->transpose->row($j)->transpose;
}



sub set {
    my $self = shift;
    
    my ($i, $j, $val);
    
    if (scalar @_ == 3) {
        $i = shift;
        $j = shift;
        $val = shift;
        @{@{$self->items()}[$i]}[$j] = $val;
    } elsif (scalar @_ == 2 && $self->numRows() == 1) {
        $j = shift;
        $val = shift;
        @{@{$self->items()}[0]}[$j] = $val;
    } elsif (scalar @_ == 2 && $self->numCols() == 1) {
        $i = shift;
        $val = shift;
        @{@{$self->items()}[$i]}[0] = $val;
    } else {
        print STDERR "\nInputs not understood.\n";  die;
    }
}



sub copy {
    my $self = shift;
    
    my $out = Matrix::zeros($self->numRows(), $self->numCols());
    
    for (my $i = 0; $i < $out->numRows(); $i++) {
        for (my $j = 0; $j < $out->numCols; $j++) {
            $out->set($i, $j, $self->item($i, $j));
        }
    }
    
    return $out;
}

################################################################################

# OPERATIONS

sub plus {
    my $self = shift;
    my $other = shift;
    
    my $numRows = $self->numRows();
    my $numCols = $self->numCols();
    
    if (ref $other && ($numRows != $other->numRows() || $numCols != $other->numCols())) {
        print STDERR "\nMatrices must be the same size to add them together.\n";  die;
    }
    
    my $sum = Matrix::zeros($numRows, $numCols);
    
    for (my $i = 0; $i < $numRows; $i++) {
        for (my $j = 0; $j < $numCols; $j++) {
            if (ref $other) {
                $sum->set($i, $j, $self->item($i, $j) + $other->item($i, $j));
            } else {
                $sum->set($i, $j, $self->item($i, $j) + $other);
            }
        }
    }
    
    return $sum;
}



sub minus {
    my $self = shift;
    my $other = shift;

    return $self->plus($other->dot(-1));
}



sub dotProduct {
    # Return the dot product of two 1D matrices of the same size.
    my $self = shift;
    my $other = shift;

    if (! ref $other) {
        print STDERR "\nInput must be a 1D matrix.\n";  die;
    }
    
    my $numRows = $self->numRows();
    my $numCols = $self->numCols();

    my $dotProduct = 0;
    
    if ($numRows != $other->numRows() || $numCols != $other->numCols()) {
        print STDERR "\nMatrices must be the same size to dot them.\n";  die;
    } elsif ($numRows != 1 && $numCols != 1) {
        print STDERR "\nThis function is only implemented for 1D matrices.\n";  die;
    } elsif ($numRows == 1) {
        for (my $j = 0; $j < $numCols; $j++) {
            $dotProduct += $self->item(0, $j) * $other->item(0, $j);
        }
    } elsif ($numCols == 1) {
        for (my $i = 0; $i < $numRows; $i++) {
            $dotProduct += $self->item($i, 0) * $other->item($i, 0);
        }
    }
    
    return $dotProduct;
}



sub transpose {
    my $self = shift;
    
    my $out = Matrix::zeros($self->numCols(), $self->numRows());
    
    for (my $i = 0; $i < $out->numRows(); $i++) {
        for (my $j = 0; $j < $out->numCols(); $j++) {
            $out->set($i, $j, $self->item($j, $i));
        }
    }
    
    return $out;
}



sub dot {
    # Multiply a matrix by a scalar, or by another matrix.
    my $self = shift;
    my $other = shift;
    
    my $prod;
    
    if (ref $other) {
        
        if ($self->numCols() != $other->numRows()) {
            print "\n\$numCols of first matrix (" . $self->numCols() . ") must equal \$numRows of second (" . $other->numRows() . ").\n";
            print "\$first = \n";
            $self->disp();
            print "\n";
            print "\$second = \n";
            $other->disp();
            die;
        }
        
        $prod = Matrix::zeros($self->numRows(), $other->numCols());
        $other = $other->transpose();
        
        for (my $i = 0; $i < $prod->numRows(); $i++) {
            for (my $j = 0; $j < $prod->numCols(); $j++) {
                $prod->set($i, $j, $self->row($i)->dotProduct($other->row($j)));
            }
        }
        
    } else {
        
        $prod = Matrix::zeros($self->numRows(), $self->numCols());
        
        for (my $i = 0; $i < $self->numRows(); $i++) {
            for (my $j = 0; $j < $self->numCols(); $j++) {
                $prod->set($i, $j, $self->item($i, $j) * $other);
            }
        }
    }
    
    return $prod;
}



sub dotTimes {
    my $self = shift;
    my $other = shift;
    
    my $numRows = $self->numRows();
    my $numCols = $self->numCols();
    
    if (! ref $other) {
        print STDERR "\nUse dot() to multiply a scalar by a matrix.\n";  die;
    } elsif ($numRows != $other->numRows() || $numCols != $other->numCols()) {
        print STDERR "\nMatrices must be the same size to (dot) multiply them together.\n";  die;
    }
    
    my $prod = Matrix::zeros($numRows, $numCols);
    
    for (my $i = 0; $i < $numRows; $i++) {
        for (my $j = 0; $j < $numCols; $j++) {
            $prod->set($i, $j, $self->item($i, $j) * $other->item($i, $j));
        }
    }
    
    return $prod;
}



sub pow {
    my $self = shift;
    my $pow = shift;
    
    my $out = $self->copy();
    
    for (my $i = 0; $i < $self->numRows(); $i++) {
        for (my $j = 0; $j < $self->numCols(); $j++) {
            $out->set($i, $j, $self->item($i, $j) ** $pow);
        }
    }
    
    return $out;
}



sub norm {
    my $self = shift;
    die "Only 1D matrices are supported right now.    " if $self->numRows() > 1 && $self->numCols() > 1;
    my $p = shift;

    $p = 2 if ! $p;
    
    my $ell;
    $ell = $self->numRows() if $self->numCols() == 1;
    $ell = $self->numCols() if $self->numRows() == 1;

    my $norm = 0;

    for (my $j = 0; $j < $ell; $j++) {
        $norm += ($self->item($j) ** $p);
    }

    return $norm ** (1 / $p);
}

################################################################################

sub swapRows {
    my $self = shift;
    my $i = shift;
    my $j = shift;
    
    my $tmp = @{$self->items()}[$i];
    @{$self->items()}[$i] = @{$self->items()}[$j];
    @{$self->items()}[$j] = $tmp;
}



sub solve {
    my $self = shift;
    my $rhs = shift;
    
    my $A = $self->copy();
    my $b = $rhs->copy();

    if ($A->numRows() != $A->numCols() || $A->numRows() != $b->numRows()) {
        print "Rows(A) = " . $A->numRows . "\n";
        print "Rows(b) = " . $b->numRows . "\n";
        print STDERR "\nA should be square.  Rows(A) should equal Rows(b).\n";  die;
    }
    
    my $nRows = $A->numRows();
    my $nCols = $A->numCols();

    # Apply row operations to transform A to upper triangular form.
    for (my $j = 0; $j < $nCols - 1; $j++) {
        # Find largest element in leftmost column, and make this the pivot row.
        # Apparently, this is important, because when I was not doing this, I
        # was getting noticeably different answers from python when the number
        # of subdomains was small.
        my $indMax = $j;
        for (my $i = $j+1; $i < $nRows; $i++) {
            if ((abs $A->item($i, $j)) > (abs $A->item($indMax, $j))) {
                $indMax = $i;
            }
        }
        # Swap row $indMax and row $j.
        $A->swapRows($indMax, $j);
        $b->swapRows($indMax, $j);
        # Zero out the $jth column.
        for (my $i = $j + 1; $i < $nRows; $i++) {
            my $factor = -1 * $A->item($i, $j) / $A->item($j, $j);
            for (my $k = $j; $k < $nCols; $k++) {
                $A->set($i, $k, $A->item($i, $k) + $factor * $A->item($j, $k));
            }
            for (my $ell = 0; $ell < $b->numCols(); $ell++) {
                $b->set($i, $ell, $b->item($i, $ell) + $factor * $b->item($j, $ell));
            }
        }
    }

    # Use back substitution to finish solving for @x.
    my $x = $b;
    for (my $ell = 0; $ell < $b->numCols(); $ell++) {
        $x->set($nRows-1, $ell, $b->item($nRows-1, $ell) / $A->item($nRows-1, $nRows-1));
    }
    my $k = $nRows;
    for (my $i = $nRows - 2; $i >= 0; $i--) {
        $k--;
        for (my $ell = 0; $ell < $b->numCols(); $ell++) {
            my $dot = 0;
            for (my $j = $k; $j < $nRows; $j++) {
                $dot += ($A->item($i, $j) * $x->item($j, $ell));
            }
            $x->set($i, $ell, ($b->item($i, $ell) - $dot) / $A->item($i, $i));
        }
    }
    return $x;
}

################################################################################

return 1;
