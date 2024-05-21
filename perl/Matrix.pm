#!/usr/bin/perl

package Matrix;

# Methods and functions for creating and manipulating Matrix objects.
# Greg Barnett
# August 2023

use strict;
use warnings;

################################################################################

# TESTS

# /mu/bin/perl -e 'use lib "/home/gregorybarne/tmpCode"; use Matrix; Matrix::test_ALL;'

sub test_new
{
    my $A = Matrix::new([[1,2,3], [4,5,6], [7,8,9]]);
    print "test_new_\$A = \n";
    $A->disp;
}



sub test_rand
{
    my $A = Matrix::rand(3, 4);
    print "test_rand_\$A = \n";
    $A->disp;
}



sub test_alloc_set
{
    my $A = Matrix::alloc(4, 3);
    
    for (my $i = 0; $i < $A->numRows; $i++)
    {
        for (my $j = 0; $j < $A->numCols; $j++)
        {
            $A->set($i, $j, 1 + rand);
        }
    }
    
    print "test_alloc_set_\$A = \n";
    $A->disp;
}



sub test_zeros_ones_eye
{
    my $A = Matrix::zeros(4, 2);
    print "test_zeros_ones_eye_\$A = \n";
    $A->disp;
    
    my $B = Matrix::ones(3, 5);
    print "test_zeros_ones_eye_\$B = \n";
    $B->disp;
    
    my $c = Matrix::eye(5);
    print "test_zeros_ones_eye_\$c = \n";
    $c->disp;
}



sub test_linspace
{
    my $x = Matrix::linspace(-1, 3, 5);
    print "test_linspace_\$x = ";
    $x->disp;
}



sub test_rows_cols
{
    my $A = Matrix::rand(5, 3);
    print "test_rows_cols_\$A = \n";
    $A->disp;
    
    my $B = $A->rows([1,4]);
    print "test_rows_cols_\$B = \n";
    $B->disp;
    
    my $C = $A->cols([0,2]);
    print "test_rows_cols_\$C = \n";
    $C->disp;
}



sub test_meshgrid
{
    my $x = Matrix::linspace(-3, 3, 7);
    my $y = Matrix::linspace(1, 5, 5);
    print "test_meshgrid_\$x = \n";
    $x->disp;
    print "test_meshgrid_\$y = \n";
    $y->disp;
    my ($xx, $yy) = Matrix::meshgrid($x, $y);
    print "test_meshgrid_\$xx = \n";
    $xx->disp;
    print "test_meshgrid_\$yy = \n";
    $yy->disp;
}



sub test_vstack
{
    my $a = Matrix::rand(3, 2);
    my $b = Matrix::ones(4, 2);
    my $c = $a->vstack($b);
    print "test_vstack_\$c = \n";
    $c->disp;
}



sub test_hstack
{
    my $a = Matrix::rand(2, 3);
    my $b = Matrix::ones(2, 4);
    my $c = $a->hstack($b);
    print "test_hstack_\$c = \n";
    $c->disp;
}



sub test_flatten
{
    my $a = Matrix::rand(3, 5);
    my $b = $a->flatten;
    print "test_flatten_\$b = \n";
    $b->disp;
}



sub test_ALL
{
    test_new;
    test_rand;
    test_alloc_set;
    test_zeros_ones_eye;
    test_linspace;
    test_rows_cols;
    test_meshgrid;
    test_vstack;
    test_hstack;
    test_flatten;
}

################################################################################

# CONSTRUCTORS

sub new
{
    # Create new matrix from a 2D array of values.
    my %self;
    my $self = \%self;
    bless $self;
    
    if (scalar @_ == 1 && ref $_[0] && ref @{$_[0]}[0])
    {
        $$self{'type'}    = 'Matrix';
        $$self{'items'}   = shift;
        $$self{'numRows'} = scalar @{$$self{'items'}};
        $$self{'numCols'} = scalar @{@{$$self{'items'}}[0]};
        
        foreach my $row (@{$$self{'items'}})
        {
            if (scalar @{$row} != $$self{'numCols'})
            {
                die "Each row should have the same number of elements.    ";
            }
        }
    }
    else
    {
        die "Bad input for new matrix.  Give ref to array of refs to arrays.    ";
    }
    
    return $self;
}



sub alloc
{
    # Allocate memory to fill in the items of a new matrix.
    # If all items will be filled, then this is faster than using zeros().
    die "Matrix::alloc() requires two inputs: numRows and numCols.    " if scalar @_ != 2;
    my ($numRows, $numCols) = @_;
    
    my @items;
    $#items = ($numRows - 1);
    
    for (my $i = 0; $i < $numRows; $i++)
    {
        my @tmp;
        $#tmp = ($numCols - 1);
        $items[$i] = \@tmp;
    }

    return Matrix::new(\@items);
}



sub zeros
{
    # New matrix of zeros.
    die "Matrix::zeros() requires two inputs: numRows and numCols.    " if scalar @_ != 2;
    my ($numRows, $numCols) = @_;
    
    my @items = ();
    
    for (my $i = 0; $i < $numRows; $i++)
    {
        my @tmp = (0) x $numCols;
        push(@items, \@tmp);
    }
    
    return Matrix::new(\@items);
}



sub ones
{
    # New matrix of ones.
    die "Matrix::ones() requires two inputs: numRows and numCols.    " if scalar @_ != 2;
    my ($numRows, $numCols) = @_;
    
    my @items = ();
    
    for (my $i = 0; $i < $numRows; $i++)
    {
        my @tmp = (1) x $numCols;
        push(@items, \@tmp);
    }
    
    return Matrix::new(\@items);
}



sub rand
{
    # New matrix whose values are randomly chosen from between 0 and 1.
    die "Matrix::rand() requires two inputs: numRows and numCols.    " if scalar @_ != 2;
    my ($numRows, $numCols) = @_;
    
    my @items = ();
    
    for (my $i = 0; $i < $numRows; $i++)
    {
        my @tmp = ();
        for (my $j = 0; $j < $numCols; $j++)
        {
            push(@tmp, rand);
        }
        push(@items, \@tmp);
    }
    
    return Matrix::new(\@items);
}



sub eye
{
    # New Identity matrix.
    die "Matrix::eye() requires one input: numRows (numCols always equals numRows).    " if scalar @_ != 1;
    my ($numRows) = @_;

    my $numCols = $numRows;
    my @items = ();
    
    for (my $i = 0; $i < $numRows; $i++)
    {
        my @tmp = ();
        for (my $j = 0; $j < $numCols; $j++)
        {
            if ($j == $i) 
            {
                push(@tmp, 1);
            }
            else
            {
                push(@tmp, 0);
            }
        }
        push(@items, \@tmp);
    }
    
    return Matrix::new(\@items);
}



sub linspace
{
    # New 1D matrix of equally-spaced values with known start and finish.
    die "Matrix::linspace() requires three inputs: start, finish, and number of points.    " if scalar @_ != 3;
    my ($a, $b, $numCols) = @_;
    
    my $dx = ($b - $a) / ($numCols - 1);
    my $item = $a;
    my @items = ();
    for (my $i = 0; $i < $numCols; $i++)
    {
        push @items, $item;
        $item += $dx;
    }
    my $numRows = 1;
    my $items = [\@items];
    
    return Matrix::new($items);
}

################################################################################

# GETTERS

sub type
{
    my $self = shift;
    return $$self{'type'};
}



sub items
{
    my $self = shift;
    return $$self{'items'};
}



sub numRows
{
    my $self = shift;
    return $$self{'numRows'};
}



sub numCols
{
    my $self = shift;
    return $$self{'numCols'};
}



sub rows
{
    # Get the rows described in the ref to array $ind.
    my $self = shift;
    my $ind = shift;
    
    my $out = Matrix::alloc(scalar @{$ind}, $self->numCols);
    
    for (my $i = 0; $i < $out->numRows;  $i++)
    {
        for (my $j = 0; $j < $out->numCols; $j++)
        {
            $out->set($i, $j, $self->item(@{$ind}[$i], $j));
        }
    }
    
    return $out;
}



sub cols
{
    # Get the columns described in the ref to array $ind.
    my $self = shift;
    my $ind = shift;
    
    my $out = Matrix::alloc($self->numRows, scalar @{$ind});
    
    for (my $i = 0; $i < $out->numRows;  $i++)
    {
        for (my $j = 0; $j < $out->numCols; $j++)
        {
            $out->set($i, $j, $self->item($i, @{$ind}[$j]));
        }
    }
    
    return $out;
}

################################################################################

sub len
{
    my $self = shift;
    return $self->numRows if $self->numCols == 1;
    return $self->numCols if $self->numRows == 1;
    die "Length is only well-defined for a 1D matrix.    ";
}



sub meshgrid
{
    my $x = shift;
    my $y = shift;
    
    my $xx = Matrix::alloc($y->numCols, $x->numCols);
    my $yy = Matrix::alloc($y->numCols, $x->numCols);
    
    for (my $i = 0; $i < $y->numCols; $i++)
    {
        for (my $j = 0; $j < $x->numCols; $j++)
        {
            $xx->set($i, $j, $x->item($j));
            $yy->set($i, $j, $y->item($i));
        }
    }
    
    return ($xx, $yy);
}



sub vstack
{
    my $self = shift;
    my $other = shift;
    
    die "Dimension mismatch.    " if $self->numCols != $other->numCols;
    
    my $out = Matrix::alloc($self->numRows + $other->numRows, $other->numCols);
    
    for (my $i = 0; $i < $self->numRows; $i++)
    {
        for (my $j = 0; $j < $self->numCols; $j++)
        {
            $out->set($i, $j, $self->item($i, $j));
        }
    }
    
    for (my $i = $self->numRows; $i < $self->numRows + $other->numRows; $i++)
    {
        for (my $j = 0; $j < $self->numCols; $j++)
        {
            $out->set($i, $j, $other->item($i - $self->numRows, $j));
        }
    }
    
    return $out;
}



sub hstack
{
    my $self = shift;
    my $other = shift;
    
    my $out;
    eval
    {
        $out = $self->transpose->vstack($other->transpose);
    };
    die if $@;
    
    return $out->transpose;
}



sub flatten
{
    my $self = shift;
    
    my $out = Matrix::alloc(1, $self->numRows * $self->numCols);
    my $k = 0;
    
    for (my $i = 0; $i < $self->numRows; $i++)
    {
        for (my $j = 0; $j < $self->numCols; $j++)
        {
            $out->set($k, $self->item($i, $j));
            $k++;
        }
    }
    
    return $out;
}



sub disp
{
    my $self = shift;
    
    foreach my $row (@{$self->items})
    {
        foreach my $item (@{$row})
        {
            printf "%10.6f ", $item;
        }
        print "\n";
    }
    
    print "\n";
}



sub item
{
    my $self = shift;
    my ($i, $j);
    
    if (scalar @_ == 2)
    {
        $i = shift;
        $j = shift;
        return @{@{$self->items}[$i]}[$j];
    }
    elsif (scalar @_ == 1 && $self->numRows == 1)
    {
        $j = shift;
        return @{@{$self->items}[0]}[$j];
    }
    elsif (scalar @_ == 1 && $self->numCols == 1)
    {
        $i = shift;
        return @{@{$self->items}[$i]}[0];
    }
}



sub row
{
    my $self = shift;
    die "Exactly one input is required.    " if scalar @_ != 1;
    my $i = shift;
    
    return Matrix::new([@{$self->items}[$i]]);
}



sub col
{
    my $self = shift;
    die "Exactly one input is required.    " if scalar @_ != 1;
    my $j = shift;

    return $self->transpose->row($j)->transpose;
}



sub set
{
    my $self = shift;    
    my ($i, $j, $val);
    
    if (scalar @_ == 3)
    {
        $i = shift;
        $j = shift;
        $val = shift;
        @{@{$self->items}[$i]}[$j] = $val;
    }
    elsif (scalar @_ == 2 && $self->numRows == 1)
    {
        $j = shift;
        $val = shift;
        @{@{$self->items}[0]}[$j] = $val;
    }
    elsif (scalar @_ == 2 && $self->numCols == 1)
    {
        $i = shift;
        $val = shift;
        @{@{$self->items}[$i]}[0] = $val;
    }
    else
    {
        print STDERR "\nInputs not understood.\n";  die;
    }
}



sub copy
{
    my $self = shift;    
    my $out = Matrix::alloc($self->numRows, $self->numCols);
    
    for (my $i = 0; $i < $out->numRows; $i++)
    {
        for (my $j = 0; $j < $out->numCols; $j++)
        {
            $out->set($i, $j, $self->item($i, $j));
        }
    }
    
    return $out;
}

################################################################################

# OPERATIONS

sub plus
{
    my $self = shift;
    my $other = shift;
    
    my $numRows = $self->numRows;
    my $numCols = $self->numCols;
    
    if (ref $other && ($numRows != $other->numRows || $numCols != $other->numCols)) {
        print STDERR "\nMatrices must be the same size to add them together.\n";  die;
    }
    
    my $sum = Matrix::alloc($numRows, $numCols);
    
    for (my $i = 0; $i < $numRows; $i++)
    {
        for (my $j = 0; $j < $numCols; $j++)
        {
            if (ref $other)
            {
                $sum->set($i, $j, $self->item($i, $j) + $other->item($i, $j));
            }
            else
            {
                $sum->set($i, $j, $self->item($i, $j) + $other);
            }
        }
    }
    
    return $sum;
}



sub minus
{
    my $self = shift;
    my $other = shift;

    return $self->plus($other->dot(-1));
}



sub dotProduct
{
    # Return the dot product of two 1D matrices of the same size.
    my $self = shift;
    my $other = shift;

    if (! ref $other)
    {
        print STDERR "\nInput must be a 1D matrix.\n";  die;
    }
    
    my $numRows = $self->numRows;
    my $numCols = $self->numCols;

    my $dotProduct = 0;
    
    if ($numRows != $other->numRows || $numCols != $other->numCols)
    {
        print STDERR "\nMatrices must be the same size to dot them.\n";  die;
    }
    elsif ($numRows != 1 && $numCols != 1)
    {
        print STDERR "\nThis function is only implemented for 1D matrices.\n";  die;
    }
    elsif ($numRows == 1)
    {
        for (my $j = 0; $j < $numCols; $j++)
        {
            $dotProduct += $self->item(0, $j) * $other->item(0, $j);
        }
    }
    elsif ($numCols == 1)
    {
        for (my $i = 0; $i < $numRows; $i++)
        {
            $dotProduct += $self->item($i, 0) * $other->item($i, 0);
        }
    }
    
    return $dotProduct;
}



sub transpose
{
    my $self = shift;
    
    my $out = Matrix::alloc($self->numCols, $self->numRows);
    
    for (my $i = 0; $i < $out->numRows; $i++)
    {
        for (my $j = 0; $j < $out->numCols; $j++)
        {
            $out->set($i, $j, $self->item($j, $i));
        }
    }
    
    return $out;
}



sub dot
{
    # Multiply a matrix by a scalar, or by another matrix.
    my $self = shift;
    my $other = shift;
    
    my $prod;
    
    if (ref $other)
    {
        if ($self->numCols != $other->numRows)
        {
            print "\n\$numCols of first matrix (" . $self->numCols . ") must equal \$numRows of second (" . $other->numRows . ").\n";
            print "\$first = \n";
            $self->disp;
            print "\n";
            print "\$second = \n";
            $other->disp;
            die;
        }
        
        $prod = Matrix::alloc($self->numRows, $other->numCols);
        $other = $other->transpose;
        
        for (my $i = 0; $i < $prod->numRows; $i++) {
            for (my $j = 0; $j < $prod->numCols; $j++) {
                $prod->set($i, $j, $self->row($i)->dotProduct($other->row($j)));
            }
        }
    }
    else
    {
        $prod = Matrix::alloc($self->numRows, $self->numCols);
        
        for (my $i = 0; $i < $self->numRows; $i++)
        {
            for (my $j = 0; $j < $self->numCols; $j++)
            {
                $prod->set($i, $j, $self->item($i, $j) * $other);
            }
        }
    }
    
    return $prod;
}



sub dotTimes
{
    my $self = shift;
    my $other = shift;
    
    my $numRows = $self->numRows;
    my $numCols = $self->numCols;
    
    if (! ref $other)
    {
        print STDERR "\nUse dot() to multiply a scalar by a matrix.\n";  die;
    }
    elsif ($numRows != $other->numRows || $numCols != $other->numCols)
    {
        print STDERR "\nMatrices must be the same size to (dot) multiply them together.\n";  die;
    }
    
    my $prod = Matrix::alloc($numRows, $numCols);
    
    for (my $i = 0; $i < $numRows; $i++)
    {
        for (my $j = 0; $j < $numCols; $j++)
        {
            $prod->set($i, $j, $self->item($i, $j) * $other->item($i, $j));
        }
    }
    
    return $prod;
}



sub pow
{
    my $self = shift;
    my $pow = shift;
    
    my $out = $self->copy();
    
    for (my $i = 0; $i < $self->numRows; $i++)
    {
        for (my $j = 0; $j < $self->numCols; $j++)
        {
            $out->set($i, $j, $self->item($i, $j) ** $pow);
        }
    }
    
    return $out;
}



sub norm
{
    my $self = shift;
    die "Only 1D matrices are supported right now.    " if $self->numRows > 1 && $self->numCols > 1;
    my $p = shift;

    $p = 2 if ! $p;
    
    my $ell;
    $ell = $self->numRows if $self->numCols == 1;
    $ell = $self->numCols if $self->numRows == 1;

    my $norm = 0;

    for (my $j = 0; $j < $ell; $j++)
    {
        $norm += (abs $self->item($j)) ** $p;
    }

    return $norm ** (1 / $p);
}

################################################################################

sub swapRows
{
    my $self = shift;
    my $i = shift;
    my $j = shift;
    
    my $tmp = @{$self->items}[$i];
    @{$self->items}[$i] = @{$self->items}[$j];
    @{$self->items}[$j] = $tmp;
}



sub solve
{
    my $self = shift;
    my $rhs = shift;
    
    my $A = $self->copy;
    my $b = $rhs->copy;

    if ($A->numRows != $A->numCols || $A->numRows != $b->numRows) {
        print "Rows(A) = " . $A->numRows . "\n";
        print "Rows(b) = " . $b->numRows . "\n";
        print STDERR "\nA should be square.  Rows(A) should equal Rows(b).\n";  die;
    }
    
    my $nRows = $A->numRows;
    my $nCols = $A->numCols;

    # Apply row operations to transform A to upper triangular form.
    for (my $j = 0; $j < $nCols - 1; $j++)
    {
        # Find largest element in leftmost column, and make this the pivot row.
        # Apparently, this is important, because when I was not doing this, I
        # was getting noticeably different answers from python when the number
        # of subdomains was small.
        my $indMax = $j;
        for (my $i = $j+1; $i < $nRows; $i++)
        {
            if ((abs $A->item($i, $j)) > (abs $A->item($indMax, $j)))
            {
                $indMax = $i;
            }
        }
        # Swap row $indMax and row $j.
        $A->swapRows($indMax, $j);
        $b->swapRows($indMax, $j);
        # Zero out the $jth column.
        for (my $i = $j + 1; $i < $nRows; $i++)
        {
            my $factor = -1 * $A->item($i, $j) / $A->item($j, $j);
            for (my $k = $j; $k < $nCols; $k++)
            {
                $A->set($i, $k, $A->item($i, $k) + $factor * $A->item($j, $k));
            }
            for (my $ell = 0; $ell < $b->numCols; $ell++)
            {
                $b->set($i, $ell, $b->item($i, $ell) + $factor * $b->item($j, $ell));
            }
        }
    }

    # Use back substitution to finish solving for @x.
    my $x = $b;
    for (my $ell = 0; $ell < $b->numCols; $ell++)
    {
        $x->set($nRows-1, $ell, $b->item($nRows-1, $ell) / $A->item($nRows-1, $nRows-1));
    }
    my $k = $nRows;
    for (my $i = $nRows - 2; $i >= 0; $i--)
    {
        $k--;
        for (my $ell = 0; $ell < $b->numCols; $ell++)
        {
            my $dot = 0;
            for (my $j = $k; $j < $nRows; $j++)
            {
                $dot += ($A->item($i, $j) * $x->item($j, $ell));
            }
            $x->set($i, $ell, ($b->item($i, $ell) - $dot) / $A->item($i, $i));
        }
    }
    
    return $x;
}

################################################################################

return 1;
