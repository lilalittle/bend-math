import Base

# Rung 2 of the RGR (red-green-refactor) formalization loop:
# the vector-calculus identities (bend-packages#68).
#
# The math: grad, curl, div are the discrete exterior derivative d at
# levels 0, 1, 2 — on a triangle (laws 1, 3) and a tetrahedron (law 2),
# over Z/2 (booleans), where subtraction is XOR.
#   grad f on edge (i,j) = f(j) - f(i)             (d of a 0-form)
#   curl F on a face     = circulation of F        (d of a 1-form)
#   div G on a tet       = flux of G through skin  (d of a 2-form)
# Laws 1 and 2 are d^2 = 0 in disguise: the boundary of a boundary is
# empty, so every edge-difference appears twice and x + x = 0.
# Law 3 says div(grad f) is the discrete Laplacian, independent of the
# edge-orientation convention used to read it.

# grad of a 0-form on edge (i,j): f(j) - f(i); over Z/2, subtraction is XOR.
def grad_edge(x: Bool, y: Bool) -> Bool:
  Bool.xor(x, y)

# curl of a 1-form on a face: alternating sum over the boundary edges.
def curl_face(p: Bool, q: Bool, r: Bool) -> Bool:
  Bool.xor(p, Bool.xor(q, r))

# div of a 2-form on a tetrahedron: alternating sum over the 4 faces.
def div_tet(w: Bool, x: Bool, y: Bool, z: Bool) -> Bool:
  Bool.xor(w, Bool.xor(x, Bool.xor(y, z)))

# curl of grad f on face 012 (vertices a, b, c).
def curl_of_grad(+a: Bool, +b: Bool, +c: Bool) -> Bool:
  curl_face(grad_edge(a, b), grad_edge(b, c), grad_edge(a, c))

# div of curl F on the tetrahedron. F is a 1-form on the 6 edges
# 01, 02, 03, 12, 13, 23; the faces are 012, 013, 023, 123.
# Every edge borders exactly 2 faces.
def div_of_curl(+e01: Bool, +e02: Bool, +e03: Bool, +e12: Bool, +e13: Bool, +e23: Bool) -> Bool:
  div_tet(curl_face(e01, e12, e02), curl_face(e01, e13, e03),
          curl_face(e02, e23, e03), curl_face(e12, e23, e13))

# div of grad f at vertex 0 of a triangle: XOR of grad over the two
# edges leaving vertex 0.
def div_of_grad(+a: Bool, +b: Bool, +c: Bool) -> Bool:
  Bool.xor(grad_edge(a, b), grad_edge(a, c))

# The discrete Laplacian at vertex 0, read with the opposite (inward)
# orientation convention: XOR over neighbors of (f(0) - f(neighbor)).
def laplacian(+a: Bool, +b: Bool, +c: Bool) -> Bool:
  Bool.xor(Bool.xor(a, b), Bool.xor(a, c))

law curl_grad_zero:
  for a: Bool
  for b: Bool
  for c: Bool
  {curl_of_grad(a, b, c) == False{} : Bool}

law div_curl_zero:
  for e01: Bool
  for e02: Bool
  for e03: Bool
  for e12: Bool
  for e13: Bool
  for e23: Bool
  {div_of_curl(e01, e02, e03, e12, e13, e23) == False{} : Bool}

law div_grad_is_laplacian:
  for a: Bool
  for b: Bool
  for c: Bool
  {div_of_grad(a, b, c) == laplacian(a, b, c) : Bool}
