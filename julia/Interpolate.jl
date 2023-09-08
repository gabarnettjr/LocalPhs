
include("LocalPhs.jl")

################################################################################

# Interpolate to estimate a value.

# Greg Barnett
# September 2023

################################################################################

rbfExponent = 3                  # odd number exponent to use in the phs rbf (3)
polyDegree = 1                      # maximum polynomial degree in the basis (1)
stencilRadius = 20          # how far away to look for neighbors of a given node

################################################################################

pathToNodes    = ARGS[1]
pathToValues   = ARGS[2]
pathToEvalPts  = ARGS[3]

# println("ARGS[1] = ", pathToNodes, ", ARGS[2] = ", pathToData, ", ARGS[3] = ", pathToEval)

nodes   = readlines(pathToNodes)
values  = readlines(pathToValues)
evalPts = readlines(pathToEvalPts)

dims = length(split(nodes[1], r"\s+"))
println("dims = $dims")
numNodes = length(nodes)
println("numNodes = $numNodes")
numEvalPts = length(evalPts)
println("numEvalPts = $numEvalPts")

nodesMatrix = zeros(numNodes, dims)
valuesMatrix = zeros(numNodes, 1)
evalPtsMatrix = zeros(numEvalPts, dims);

for i = 1 : numNodes
    tmp = split(nodes[i], r"\s+")
    for j = 1 : dims
        nodesMatrix[i, j] = parse(Float64, tmp[j])
    end
    valuesMatrix[i, 1] = parse(Float64, values[i])
end

for i = 1 : numEvalPts
    tmp = split(evalPts[i], r"\s+")
    for j = 1 : dims
        evalPtsMatrix[i, j] = parse(Float64, tmp[j])
    end
end

nodesMatrix = nodesMatrix .+ rand(size(nodesMatrix, 1), size(nodesMatrix, 2))
valuesMatrix = valuesMatrix .+ rand(size(valuesMatrix, 1), size(valuesMatrix, 2))
evalPtsMatrix = evalPtsMatrix .+ rand(size(evalPtsMatrix, 1), size(evalPtsMatrix, 2))

println("nodes = ", nodesMatrix)
println("values = ", valuesMatrix)
println("evalPts = ", evalPtsMatrix)

# phs = LocalPhs_new(3, 1, nodesMatrix, valuesMatrix, 10.0)
# estimates = LocalPhs_evaluate(phs, evalPtsMatrix)








