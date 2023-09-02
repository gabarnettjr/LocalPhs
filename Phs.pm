#!/usr/bin/perl

package Phs;

# Polyharmonic Spline (PHS) interpolation class, for creating Phs objects.
# Greg Barnett
# August 2023

use strict;
use warnings;

use lib ".";
use Matrix;

################################################################################

# CONSTRUCTOR

sub new {
    # New object of type Phs
    die "Required number of inputs is 4.    " if scalar @_ != 4;
    my $dims = undef;
    my $rbfExponent = shift;
    my $polyDegree = shift;
    my $nodes = shift;
    my $vals = shift;
    my $coeffs = undef;
    
    my $self = ["Phs", $dims, $rbfExponent, $polyDegree, $nodes, $vals, $coeffs];
    bless $self;
    return $self;
}

################################################################################

# GETTERS

sub type {
    my $self = shift;
    return ${$self}[0];
}



sub dims {
    # Number of dimensions of the PHS (1, 2, 3, ...)
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::dims", '0', scalar @_); };  die if $@;
    
    my $dims = @{$self}[1];
    return $dims if defined $dims;
    
    $dims = $self->nodes->numCols;
    @{$self}[1] = $dims;
    return $dims if ! scalar @_;
    die "Failed to get dimensions.\n";
}



sub rbfExponent {
    # Exponent in the PHS basis function (1, 3, 5, ...)
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::rbfExponent", '0', scalar @_); };  die if $@;
    
    my $rbfExponent = @{$self}[2];
    return $rbfExponent if defined $rbfExponent;
    die "Failed to get RBF exponent.";
}



sub polyDegree {
    # Highest polynomial degree included in the interpolation basis.
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::polyDegree", '0', scalar @_); };  die if $@;
    
    my $polyDegree = @{$self}[3];
    return $polyDegree if defined $polyDegree;
    die "Failed to get the max polynomial degree.";
}



sub nodes {
    # Inputs where the PHS function has a known output (value)
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::nodes", '^0$|^1$', scalar @_); };  die if $@;
    
    my $nodes = @{$self}[4];
    return $nodes if defined $nodes && ! scalar @_;
    return $nodes->row(shift) if defined $nodes;
    die "Failed to get the nodes.";
}



sub vals {
    # Known function vals that the PHS must match at the nodes
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::vals", '^0$|^1$', scalar @_); };  die if $@;
    
    my $vals = @{$self}[5];
    return $vals if defined $vals && ! scalar @_;
    return $vals->row(shift) if defined $vals;
    die "Failed to get the function values at the nodes.";
}



sub coeffs {
    # Use the nodes and function vals to determine the PHS coefficients.
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::coeffs", '^0$|^1$', scalar @_); };  die if $@;
    
    my $coeffs = @{$self}[6];
    return $coeffs if defined $coeffs;
    
    # Make the combined RBF plus polynomial A-matrix.
    my ($A, $p, $null);
    eval {
        $A = $self->phi($self->r($self->nodes));
        $p = $self->poly($self->nodes);
        $A = $A->hstack($p);
        $null = Matrix::zeros($p->numCols, $p->numCols);
        $A = $A->vstack($p->transpose->hstack($null));
    };
    die if $@;
    
    # Solve a linear system to get the coefficients.
    $null = Matrix::zeros($p->numCols, 1);
    $coeffs = $A->solve($self->vals->vstack($null));
    @{$self}[6] = $coeffs;
    return $coeffs if ! scalar @_;
    die "Failed to get PHS coefficients.";
}

################################################################################

sub poly {
    # The polynomial portion of the combined A-matrix.
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::poly", '1', scalar @_); };  die if $@;
    my $evalPts = shift;
    
    my $poly = Matrix::ones($evalPts->numRows, 1);
    
    if ($self->polyDegree >= 1) {
        for (my $k = 0; $k < $self->dims; $k++) {
            $poly = $poly->hstack($evalPts->col($k));
        }
    }
    
    # if ($self->polyDegree >= 2) {
        # my $tmp = 2;
        # for (my $k1 = 0; $k1 < $self->dims; $k1++) {
            # for (my $k2 = 0; $k2 < $self->dims; $k2++) {
                # if ($k1 + $k2 == 2) {
                    # $poly = $poly->vstack($evalPts->row($k1)->pow($k1)->dot($evalPts->row($k2)->pow($k2))) 
                # }
            # }
        # }
    # }
    
    return $poly;
}



sub evaluate {
    # Evaluate the PHS at the $evalPts.
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::evaluate", '1', scalar @_); };  die if $@;
    my $evalPts = shift;
    
    my $out;
    eval {
        $out = $self->phi($self->r($evalPts))->hstack($self->poly($evalPts))->dot($self->coeffs);
    };
    die if $@;
    
    return $out;
}



sub r {
    # Radius matrix that can be used to create an A-matrix using an RBF.
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::r", '1', scalar @_); };  die if $@;
    my $evalPts = shift;
    
    my ($r, $i, $j, $tmp);
    
    eval {
        $r = Matrix::zeros($evalPts->numRows, $self->nodes->numRows);
        
        for ($i = 0; $i < $evalPts->numRows; $i++) {
            for ($j = 0; $j < $self->nodes->numRows; $j++) {
                $tmp = 0;
                for (my $k = 0; $k < $self->dims; $k++) {
                    $tmp += ($evalPts->item($i, $k) - $self->nodes->item($j, $k)) ** 2;
                }
                $r->set($i, $j, sqrt $tmp);
            }
        }  
    };
    die if $@;
    
    return $r;
}



sub phi {
    # The RBF portion of the combined A-matrix.
    my $self = shift;
    eval { Phs::checkNumInputs("Phs::phi", '1', scalar @_); };  die if $@;
    my $r = shift;
    
    my ($i, $j);
    my $phi = Matrix::zeros($r->numRows, $r->numCols);
    
    for ($i = 0; $i < $phi->numRows; $i++) {
        for ($j = 0; $j < $phi->numCols; $j++) {
            $phi->set($i, $j, $r->item($i, $j) ** $self->rbfExponent);
        }
    }
    
    return $phi;
}



sub testFunc2d {
    my $evalPts = shift;
    
    my $i;
    my $out = Matrix::zeros($evalPts->numRows, 1);
    
    for ($i = 0; $i < $out->numRows; $i++) {
        $out->set($i, $evalPts->item($i, 0) ** 2 + $evalPts->item($i, 1));
    }
    
    return $out;
}

################################################################################

sub checkNumInputs {
    my ($subName, $reqArgs, $numArgs) = @_;
    die "$subName() requires $reqArgs input(s), but you gave $numArgs\t" if $reqArgs !~ /$numArgs/;
}

return 1;
