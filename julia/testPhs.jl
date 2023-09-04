
include("Phs.jl")

rbfExponent = 3
polyDegree = 1

# Define spatial domain [a,b] x [c,d], with m rows and n columns.
a = -1;  b = 1;  n = 6
c = -1;  d = 1;  m = 6

# Define number of rows (M) and columns (N) for evaluation points.
M = 10
N = 10

################################################################################

function  makeNodes(x, y)
    n = length(x)
    m = length(y)
    xx = zeros(m * n, 1)
    yy = zeros(m * n, 1)
    k = 1
    for i = 1 : m
        for j = 1 : n
            xx[k] = x[j]
            yy[k] = y[i]
            k += 1
        end
    end
    nodes = hcat(xx, yy)
    return nodes
end

x = range(a, stop = b, length = n)
y = range(c, stop = d, length = m)
nodes = makeNodes(x, y)
zz = Phs_testFunc2d(nodes)

X = range(a, stop = b, length = N)
Y = range(c, stop = d, length = M)
NODES = makeNodes(X, Y)
ZZ = Phs_testFunc2d(NODES)

spline = Phs_new(rbfExponent, polyDegree, nodes, zz)
estimate = Phs_evaluate(spline, NODES)

println("estimate = ")
println(transpose(estimate))
println("ZZ = ")
println(transpose(ZZ))
println()
diff = estimate - ZZ
println("diff = ")
println(transpose(diff))
