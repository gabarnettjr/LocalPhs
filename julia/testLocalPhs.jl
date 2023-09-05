
using LinearAlgebra
using HaltonSequences

include("LocalPhs.jl")

################################################################################

# A script for testing the speed and accuracy of local polyharmonic spline (PHS)
# interpolation of scattered data in high dimensions (up to 7).

# Greg Barnett
# September 2023

################################################################################

dims = 5                                      # dimensions (1, 2, 3, 4, 5, 6, 7)
rbfExponent = 3                  # odd number exponent to use in the phs rbf (3)
polyDegree = 1                      # maximum polynomial degree in the basis (1)
a = -1;  b = 1                  # bounds on the domain (used for all dimensions)
nNodes = 100000                                                # number of nodes
nEvalPts = 100                                     # number of evaluation points
stencilRadius = 6/16        # how far away to look for neighbors of a given node
useHalton = false        # boolean to decide if you want to use halton or random

################################################################################

base1 = [2 5 11 17 23 31 41]            # base of primes for making halton nodes
base2 = [3 7 13 19 29 37 43]         # base of primes for making halton eval pts

# Get the nodes and evaluate the test function there.
nodes = rand(nNodes, dims)
if useHalton
    h = HaltonPoint(base1[1:dims], length=nNodes)
    for i = 1 : size(nodes, 1)
        nodes[i,:] = h[i]
    end
end
nodes = nodes * (b - a) .+ a
zzNodes = Phs_testFunc(nodes)

# Get the evaluation points and evaluate the test function there.
evalPts = rand(nEvalPts, dims)
if useHalton
    h = HaltonPoint(base2[1:dims], length=nEvalPts)
    for i = 1 : size(evalPts, 1)
        evalPts[i,:] = h[i]
    end
end
evalPts = evalPts * (0.80 * (b - a)) .+ (a + 0.10 * (b - a))
# evalPts = evalPts * (b - a) .+ a
zzEvalPts = Phs_testFunc(evalPts)
# println("minEvalPt = ", minimum(evalPts))
# println("maxEvalPt = ", maximum(evalPts))

# Use local polyharmonic spline interpolation to estimate values at evalPts.
phs = LocalPhs_new(rbfExponent, polyDegree, nodes, zzNodes, stencilRadius)
estimate = LocalPhs_evaluate(phs, evalPts)

# Check the error against the true underlying function at the evalPts.
diff = abs.(estimate[:] - zzEvalPts[:])
avgErr = norm(diff, 1) / length(diff)
println("average error = ", avgErr)
println("maximum error = ", norm(diff, Inf))
println("error std dev = ", norm(diff .- avgErr, 2) / (length(diff) - 1))

