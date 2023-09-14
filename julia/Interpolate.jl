
using Printf

include("LocalPhs.jl")

################################################################################

# Interpolate locally to estimate values.

# Greg Barnett
# September 2023

################################################################################

rbfExponent = 0                  # odd number exponent to use in the phs rbf (3)
polyDegree = 1                      # maximum polynomial degree in the basis (1)
stencilRadius = 1/32            # how far away to look (initially) for neighbors
debug = false

pathToNodes     = ARGS[1]
pathToValues    = ARGS[2]
pathToEvalPts   = ARGS[3]
pathToEstimates = ARGS[4]

println("rbfExponent = ", rbfExponent)
println("polyDegree  = ", polyDegree)
println("ARGS[1] = ", pathToNodes)
println("ARGS[2] = ", pathToValues)
println("ARGS[3] = ", pathToEvalPts)
println("ARGS[4] = ", pathToEstimates)

################################################################################

# Get the variables as array of lines from the text files.
nodes   = readlines(pathToNodes)
values  = readlines(pathToValues)
evalPts = readlines(pathToEvalPts)

# Determine the number of dimensions.
tmp = split(nodes[1], r"\s+")
if ! contains(tmp[1], r"\S+");  tmp = tmp[2:end];  end
dims = length(tmp)
println("dims = $dims")

# Count the number of nodes.
numNodes = length(nodes)
println("numNodes = $numNodes")

# Count the number of evaluation points.
numEvalPts = length(evalPts)
println("numEvalPts = $numEvalPts")


################################################################################

# Get the nodes, values, and evalPts in matrix form, to be used by LocalPhs.jl

nodesMatrix   = zeros(numNodes,   dims)
valuesMatrix  = zeros(numNodes,   1)
evalPtsMatrix = zeros(numEvalPts, dims)

if debug;  print("nodesMatrix = \n");  end

for i = 1 : numNodes
    local tmp = split(nodes[i], r"\s+")
    if ! contains(tmp[1], r"\S+");  tmp = tmp[2:end];  end
    for j = 1 : dims
        nodesMatrix[i, j] = parse(Float64, tmp[j])
        if debug;  @printf("% 1.2e ", nodesMatrix[i, j]);  end
    end
    if debug;  print("END\n");  end
end

if debug;  print("END\n\n");  end

if debug;  print("valuesMatrix = \n");  end

for i = 1 : numNodes
    valuesMatrix[i, 1] = parse(Float64, values[i])
    if debug;  @printf("% 1.2e\n", valuesMatrix[i, 1]);  end
end

if debug;  print("END\n\n");  end

if debug;  print("evalPtsMatrix = \n");  end

for i = 1 : numEvalPts
    local tmp = split(evalPts[i], r"\s+")
    if ! contains(tmp[1], r"\S+");  tmp = tmp[2:end];  end
    for j = 1 : dims
        evalPtsMatrix[i, j] = parse(Float64, tmp[j])
        if debug;  @printf("% 1.2e ", evalPtsMatrix[i, j]);  end
    end
    if debug;  print("END\n");  end
end

if debug;  print("\n");  end

################################################################################

# Get the mean of the data in each dimension.
means = sum(nodesMatrix, dims=1) ./ numNodes

# Get the standard deviation of the data in each dimension.
stds = sqrt.(sum((nodesMatrix .- repeat(means, numNodes, 1)) .^2, dims=1))

# Scale the nodes so each dimension has mean 0 and std 1.
# Also scale the evalPts in the same way so they can be used.
nodesMatrix = (nodesMatrix .- repeat(means, numNodes, 1)) ./ repeat(stds, numNodes, 1)
evalPtsMatrix = (evalPtsMatrix .- repeat(means, numEvalPts, 1)) ./ repeat(stds, numEvalPts, 1)

################################################################################

# Take care of nodes that are too close to each other (basically the same).

for i = numNodes : -1 : 2
    for j = 1 : i - 1
        if (norm(nodesMatrix[i, :] - nodesMatrix[j, :]) < .00001)
            println("Averaging nodes $i (", nodesMatrix[i,:], ", ", valuesMatrix[i,1], ") and $j (", nodesMatrix[j,:], ", ", valuesMatrix[j,1], ").")
            global nodesMatrix[j, :]  = (nodesMatrix[j, :]  + nodesMatrix[i, :])  / 2
            global valuesMatrix[j, :] = (valuesMatrix[j, :] + valuesMatrix[i, :]) / 2
            if (i == size(nodesMatrix, 1))
                global nodesMatrix  = nodesMatrix[1:i-1, :]
                global valuesMatrix = valuesMatrix[1:i-1, :]
            else
                global nodesMatrix  = vcat( nodesMatrix[1:i-1, :], nodesMatrix[i+1:end, :] )
                global valuesMatrix = vcat(valuesMatrix[1:i-1, :], valuesMatrix[i+1:end, :])
            end
        end
    end
end

################################################################################

# Use a local PHS interpolant to estimate the function at the evalPts.
phs = LocalPhs_new(rbfExponent, polyDegree, nodesMatrix, valuesMatrix, stencilRadius)
estimates = LocalPhs_evaluate(phs, evalPtsMatrix)

# Save the estimates in a text file.
open(pathToEstimates, "w") do file
    for i = 1 : length(estimates)
        @printf(file, "% 5.3f\n", estimates[i])
    end
end
println("Estimates saved to file \"$pathToEstimates\"")

################################################################################

