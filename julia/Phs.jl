# using LinearAlgebra

mutable struct Phs
    dims::UInt
    rbfExponent::UInt
    polyDegree::UInt
    nodes::Array{Float64,2}
    vals::Array{Float64,1}
    coeffs::Array{Float64,1}
end

# function Phs_coeffs(phs::Phs)
    # A = Phs_phi(Phs_r(Phs.nodes)
# end

dims = 2
rbfExponent = 3
polyDegree = 1
nodes = [1 2; 3 4; 5 6]
vals = [1; 2; 3]

phs = Phs(dims, rbfExponent, polyDegree, nodes, vals)
