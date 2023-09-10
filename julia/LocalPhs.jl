
using LinearAlgebra

include("Phs.jl")

# Mutable structure (attributes) and methods for creating objects of type
# LocalPhs.  PHS stands for polyharmonic spline, and it is a particular type of
# radial basis function (RBF) that does not have a "shape parameter."  When
# given a collection of nodes and corresponding known function values at the
# nodes, a LocalPhs object can be used to interpolate the known data locally and
# estimate the value of the underlying function on a collection of so-called
# evaluation points.  The interpolation is local because it is constructed using
# only the nodes in a specified radius (stencilRadius) of an evaluation point.

# Greg Barnett
# September 2023

################################################################################

mutable struct LocalPhs
    dims::Int64

    rbfExponent::Int64
    polyDegree::Int64
    nodes::Matrix{Float64}
    vals::Matrix{Float64}
    stencilRadius::Float64

    splines::Array{Phs}
end

################################################################################

function LocalPhs_new(rbfExponent::Int64, polyDegree::Int64, nodes::Matrix{Float64}, vals::Matrix{Float64}, stencilRadius::Float64)
    dims = size(nodes, 2)
    phs = Phs_new(rbfExponent, polyDegree, zeros(1, 1), zeros(1, 1))
    splines = fill(phs, size(nodes, 1))
    self = LocalPhs(dims, rbfExponent, polyDegree, nodes, vals, stencilRadius, splines)
    return self
end

################################################################################

function LocalPhs_splines(self::LocalPhs, ind::Int64)
    if ! self.splines[ind].isNull
        print("Stencil-size = ", self.splines[ind].stencilSize, ".  Re-used a spline.  ")
        return self.splines[ind]
    end

    tmpRadius = self.stencilRadius
    stencil = zeros(1, self.dims)
    vals = zeros(1, 1)

    while (true)
        diff = zeros(1, self.dims)
        stencil = zeros(1, self.dims)
        val = zeros(1, 1)
        vals = zeros(1, 1)
        vals[1,:] = self.vals[ind, :]
        
        for k = 1 : size(self.nodes, 1)
            diff[1,:] = self.nodes[k, :] - self.nodes[ind, :]
            val[1,:] = self.vals[k,:]
            if (k != ind) && (norm(diff) < tmpRadius)
                stencil = vcat(stencil, diff)
                vals = vcat(vals, val)
            end
        end

        if (size(stencil, 1) >= 20) && (size(stencil, 1) <= 300)
            break
        elseif (size(stencil, 1) < 20)
            tmpRadius += self.stencilRadius
        elseif (size(stencil, 1) > 300)
            tmpRadius /= 2
        end
    end

    self.splines[ind] = Phs_new(self.rbfExponent, self.polyDegree, stencil, vals)
    
    println("Stencil-size = ", size(stencil, 1), ".  stencil-radius = ", tmpRadius)
    
    return self.splines[ind]
end

################################################################################

function LocalPhs_evaluate(self::LocalPhs, evalPts::Matrix{Float64})
    ind = 0
    diff = zeros(1, self.dims)
    out = zeros(size(evalPts, 1), 1)

    t = time()
    
    for i = 1 : size(evalPts, 1)
        point = evalPts[i, :]
        min = 99
        for j = 1 : size(self.nodes, 1)
            node = self.nodes[j, :]
            dist = norm(point - node)
            if (dist < min)
                min = dist
                ind = j
            end
        end
        diff[1, :] = point - self.nodes[ind, :]
        out[i] = Phs_evaluate(LocalPhs_splines(self, ind), diff)[1, 1]
    end
    
    t = time() - t
    
    println("It took $t seconds to evaluate ", size(evalPts, 1), " local interpolants on ", size(self.nodes, 1), " nodes in ", self.dims, " dimensions.")
    
    return out
end

################################################################################


