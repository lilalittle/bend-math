import Base

# Step zero of the RGR (red-green-refactor) formalization loop.
#
# The math: d^2 = 0, the seed of Stokes' theorem, on the smallest model
# that isn't vacuous — a single triangle, with Z/2 (boolean) coefficients.
#
# A 0-form assigns a value to each vertex. Its exterior derivative d
# assigns to each edge the *difference* of the endpoint values.
# The derivative of a 1-form assigns to the face the signed sum over
# the boundary edges. d^2 = 0 says: the boundary of a boundary is empty —
# every edge gets counted twice, and x + x = 0.

# d of a 0-form on an edge (i,j): value(j) - value(i).
# Over Z/2, subtraction is XOR.
def d0_edge(x: Bool, y: Bool) -> Bool:
  Bool.xor(x, y)

# d of a 1-form on the face: alternating sum over the boundary edges.
def d1_face(p: Bool, q: Bool, r: Bool) -> Bool:
  Bool.xor(p, Bool.xor(q, r))

# d^2 of a 0-form (a, b, c) on vertices (0, 1, 2); edges are 01, 12, 02.
def d2(+a: Bool, +b: Bool, +c: Bool) -> Bool:
  d1_face(d0_edge(a, b), d0_edge(b, c), d0_edge(a, c))

law d2_zero:
  for a: Bool
  for b: Bool
  for c: Bool
  {d2(a, b, c) == False{} : Bool}
