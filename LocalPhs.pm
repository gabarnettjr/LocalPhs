#!/usr/bin/perl

package LocalPhs;

use strict;
use warnings;

use lib ".";
use Phs;

################################################################################

sub new {
    die "Requires five inputs.    " if scalar @_ != 5;
    my $dims = undef;
    my $rbfExponent = shift;
    my $polyDegree = shift;
    my $nodes = shift;
    my $vals = shift;
    my $splines = undef;
    my $stencilRadius = shift;
    
    my $self = ["LocalPhs", $dims, $rbfExponent, $polyDegree, $nodes, $vals, $splines, $stencilRadius];
    bless $self;
    return $self;
}

################################################################################

sub type {
    my $self = shift;
    return @{$self}[0];
}

################################################################################

sub dims {
    # Number of dimensions of the PHS (1, 2, 3, ...)
    my $self = shift;
    die "Too many inputs.    " if scalar @_;
    
    my $dims = @{$self}[1];
    return $dims if defined $dims;
    return $self->nodes->numCols;
}

################################################################################

sub rbfExponent {
    my $self = shift;
    return @{$self}[2];
}

################################################################################

sub polyDegree {
    my $self = shift;
    return @{$self}[3];
}

################################################################################

sub nodes {
    my $self = shift;
    my $nodes = @{$self}[4];
    return $nodes if defined $nodes && ! scalar @_;
    return $nodes->row(shift) if defined $nodes;
    die "Failed to get nodes.";
}

################################################################################

sub vals {
    my $self = shift;
    my $vals = @{$self}[5];
    return $vals if defined $vals && ! scalar @_;
    return $vals->row(shift) if defined $vals;
    die "Failed to get function values.";
}

################################################################################

sub splines {
    my $self = shift;
    my $splines = @{$self}[6];
    return $splines if defined $splines && ! scalar @_;
    return @{$splines}[shift] if defined $splines;

    $splines = [];
    my ($stencil, $vals, $j, $k);

    for ($j = 0; $j < $self->nodes->numRows; $j++) {
        $stencil = Matrix::zeros(1, $self->nodes->numCols);
        $vals = $self->vals->row($j);
        for ($k = 0; $k < $self->nodes->numRows; $k++) {
            if ($k != $j && $self->nodes->row($j)->minus($self->nodes->row($k))->norm < $self->stencilRadius) {
                $stencil = $stencil->vstack($self->nodes->row($k)->minus($self->nodes->row($j)));
                $vals = $vals->vstack($self->vals->row($k));
            }
        }
        my $phs = Phs::new($self->rbfExponent, $self->polyDegree, $stencil, $vals);
        push(@{$splines}, $phs);
    }
    
    @{$self}[6] = $splines;
    return $splines if ! scalar @_;
    return @{$splines}[shift];
    die "Failed to get polyharmonic spline(s).";
}

################################################################################

sub stencilRadius {
    my $self = shift;
    return @{$self}[7];
}

################################################################################

sub evaluate {
    my $self = shift;
    my $evalPts = shift;
    
    my ($min, $ind, $i, $j, $point, $node, $dist, $out);
    
    $out = Matrix::zeros($evalPts->numRows, 1);
    
    for ($i = 0; $i < $evalPts->numRows; $i++) {
        $point = $evalPts->row($i);
        $min = 99;
        for ($j = 0; $j < $self->nodes->numRows; $j++) {
            $node = $self->nodes->row($j);
            $dist = ($point->minus($node))->norm;
            if ($dist < $min) {
                $min = $dist;
                $ind = $j;
            }
        }
        $out->set($i, $self->splines($ind)->evaluate($point->minus($self->nodes->row($ind)))->item(0, 0));
    }
    
    return $out;
}

################################################################################

return 1;

