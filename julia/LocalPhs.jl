
include("Phs.jl")

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

    diff = zeros(1, self.dims)
    stencil = zeros(1, self.dims)
    val = zeros(1, 1)
    vals = zeros(1, 1)
    vals[1,:] = self.vals[ind, :]
    
    for k = 1 : size(self.nodes, 1)
        diff[1,:] = self.nodes[k, :] - self.nodes[ind, :]
        val[1,:] = self.vals[k,:]
        if (k != ind) && (norm(diff) < self.stencilRadius)
            stencil = vcat(stencil, diff)
            vals = vcat(vals, val)
        end
    end
    
    self.splines[ind] = Phs_new(self.rbfExponent, self.polyDegree, stencil, vals)
    
    println("Stencil-size = ", size(stencil, 1))
    
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
    
    println("To evaluate local interpolants took ", t, " seconds.")
    
    return out
end

################################################################################


