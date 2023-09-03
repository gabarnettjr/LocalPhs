# using LinearAlgebra

mutable struct Phs {
    rbfExponent::UInt
    polyDegree::UInt
    nodes::Float64{2}
    vals::Float64{1}
end

