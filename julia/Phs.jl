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
