
# Mutable structure (attributes) and methods for creating and manipulating Phs
# objects.  PHS stands for Polyharmonic Spline, which is a certain type of
# radial basis function (RBF) that does not require a "shape parameter."
# The Phs object can be used by itself to create global approximations, or it
# can be used many times during the creation of a LocalPhs object.
# See LocalPhs.jl for more information on local PHS approximations.

# Greg Barnett
# September 2023

################################################################################

mutable struct Phs
    isNull::Bool
    stencilSize::Int64
    dims::Int64

    rbfExponent::Int64
    polyDegree::Int64
    nodes::Matrix{Float64}
    vals::Matrix{Float64}

    coeffs::Matrix{Float64}
end

################################################################################

function Phs_new(rbfExponent::Int64, polyDegree::Int64, nodes::Matrix{Float64}, vals::Matrix{Float64})
    # Make a new object of type Phs.
    if (nodes == zeros(1, 1)) && (vals == zeros(1, 1))
        isNull = true
    else
        isNull = false
    end
    self = Phs(isNull, size(nodes, 1), size(nodes, 2), rbfExponent, polyDegree, nodes, vals, zeros(1, 1))
    return self
end

################################################################################

function Phs_coeffs(self::Phs)
    # Use the nodes and function vals to determine the Phs coefficients.
    if ! (self.coeffs == zeros(1, 1))
        println("Re-used coefficients.")
        return self.coeffs
    end
    
    # Make the combined RBF plus polynomial A-matrix.
    A = Phs_phi(self, self.nodes)
    p = Phs_poly(self, self.nodes)
    A = hcat(A, p)
    null = zeros(size(p, 2), size(p, 2))
    A = vcat(A, transpose(vcat(p, null)))
    
    # Solve a linear system to get the coefficients.
    null = zeros(size(p, 2), 1)
    self.coeffs = A \ vcat(self.vals, null)
    return self.coeffs
end

################################################################################

function Phs_poly(self::Phs, evalPts::Matrix{Float64})
    # The polynomial portion of the combined A-matrix.
    poly = ones(size(evalPts, 1), 1)
    
    if (self.polyDegree >= 1)
        for k = 1 : self.dims
            poly = hcat(poly, evalPts[:,k])
        end
    end
    
    return poly
end

################################################################################

function Phs_evaluate(self::Phs, evalPts::Matrix{Float64})
    # Evaluate the Phs at the evalPts.
    
    out = hcat(Phs_phi(self, evalPts), Phs_poly(self, evalPts)) * Phs_coeffs(self)
    
    return out
end

################################################################################

function Phs_phi(self::Phs, evalPts::Matrix{Float64})
    # Radius matrix that can be used to create an A-matrix using an RBF.
    phi = zeros(size(evalPts, 1), self.stencilSize)
    
    for i = 1 : size(evalPts, 1)
        for j = 1 : self.stencilSize
            r = 0
            for k = 1 : self.dims
                r += (evalPts[i, k] - self.nodes[j, k]) ^ 2
            end
            phi[i, j] = sqrt(r) ^ self.rbfExponent
        end
    end
    
    return phi
end

################################################################################

function Phs_testFunc(evalPts::Matrix{Float64})
    out = zeros(size(evalPts, 1), 1)
    
    for i = 1 : size(evalPts, 1)
        tmp = 1
        for j = 1 : size(evalPts, 2)
            tmp *= cos(pi * evalPts[i, j])
            # tmp += evalPts[i, j]
        end
        out[i] = tmp
    end
    
    return out
end

################################################################################


