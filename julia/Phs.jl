# using LinearAlgebra

mutable struct Phs
    rbfExponent::UInt
    polyDegree::UInt
    nodes::Array{Float64,2}
    vals::Array{Float64,1}
end

phs = Phs(3, 1, [1 2; 3 4; 5 6], [1;2;3])
