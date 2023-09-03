
include("Phs.jl")

dims = 2
rbfExponent = 3;
polyDegree = 1;

# Define spatial domain [a,b] x [c,d], with m rows and n columns.
a = -1;  b = 1;  n = 6
c = -1;  d = 1;  m = 6

# Define number of rows (M) and columns (N) for evaluation points.
M = 10;
N = 10;

################################################################################

x = range(a, stop = b, steps = n)
y = range(c, stop = d, steps = m)
xx = []
yy = []
k = 1
for i = 1 : m
    for j = 1 : n
        xx = vcat(xx, x[j])
        yy = vcat(yy, y[i])
    end
end
nodes = hcat(xx, yy)
zz = Phs_testFunc2d(nodes)

X = range(a, stop = b, steps = M)
Y = range(c, stop = d, steps = M)
XX = []
YY = []
k = 1
for i = 1 : M
    for j = 1 : N
        XX = vcat(XX, X[j])
        YY = vcat(Y, Y[i])
    end
end
NODES = hcat(XX, YY)
ZZ = Phs_testFunc2d(NODES)

spline = Phs();
spline.dims = size(nodes, 2)
spline.rbfExponent = rbfExponent
spline.polyDegree = polyDegree
spline.nodes = nodes

estimate = Phs_evaluate(spline, NODES)

print("estimate = ";
print(transpose(estimate))
print("\n")
print("ZZ = \n")
print(transpose(ZZ))
print("\n")
diff = estimate - ZZ
print("diff = \n")
print(transpose(diff))
