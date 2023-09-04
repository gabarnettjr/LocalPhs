
using LinearAlgebra

include("LocalPhs.jl")

################################################################################

dims = 3                                                            # dimensions
rbfExponent = 3                      # odd number exponent to use in the phs rbf
polyDegree = 1                          # maximum polynomial degree in the basis
a = -1;  b = 1                                            # bounds on the domain
n = 1000                                                       # number of nodes
N = 100                                            # number of evaluation points
stencilRadius = 4/8         # how far away to look for neighbors of a given node

################################################################################

nodes = rand(n, dims)
nodes = nodes * (b - a) .+ a
zz = Phs_testFunc2d(nodes)

NODES = rand(N, dims)
NODES = NODES * (b - a) .+ a
ZZ = Phs_testFunc2d(NODES)

phs = LocalPhs_new(rbfExponent, polyDegree, nodes, zz, stencilRadius)
estimate = LocalPhs_evaluate(phs, NODES)

diff = estimate - ZZ
println("average error = ", norm(diff, 1) / length(diff))
println("maximum error = ", norm(diff, Inf))

