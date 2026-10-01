import Base

# Rung 4 of the RGR (red-green-refactor) formalization loop:
# the discrete divergence theorem (bend-packages#84),
# the finitary shadow of Stokes' theorem.
#
# The math: on a cubical complex, div of a discrete 2-form (face fluxes)
# on a cube is the XOR over its 6 faces. Summing div over the cubes, every
# interior face is incident to exactly 2 cubes, so its value appears twice
# and cancels (x + x = 0 over Z/2) — what survives is exactly the flux
# through the closed outer boundary. Over Z/2 orientation is invisible, so
# "opposite orientations cancel" becomes "the shared value appears twice";
# the incidence content is what's proved.
#
# Smallest non-vacuous instance: two cubes sharing one face
# (one cube would be true by definition — div IS the boundary flux).

# div of a 2-form on a cube: XOR over the 6 faces (d at level 2 -> 3).
def div_cube(f0: Bool, f1: Bool, f2: Bool, f3: Bool, f4: Bool, f5: Bool) -> Bool:
  Bool.xor(f0, Bool.xor(f1, Bool.xor(f2, Bool.xor(f3, Bool.xor(f4, f5)))))

# Flux through the closed boundary of the two-cube complex:
# XOR over the 10 non-shared (outer) faces, grouped per cube.
def boundary_flux(a1: Bool, a2: Bool, a3: Bool, a4: Bool, a5: Bool,
                  b1: Bool, b2: Bool, b3: Bool, b4: Bool, b5: Bool) -> Bool:
  Bool.xor(Bool.xor(a1, Bool.xor(a2, Bool.xor(a3, Bool.xor(a4, a5)))),
           Bool.xor(b1, Bool.xor(b2, Bool.xor(b3, Bool.xor(b4, b5)))))

# THE DIVERGENCE THEOREM, discretely: cube A = (s, a1..a5) and
# cube B = (s, b1..b5) share the interior face s. The sum of the
# divergences equals the flux through the outer boundary — the
# shared face cancels.
law divergence_two_cubes:
  for s: Bool
  for a1: Bool
  for a2: Bool
  for a3: Bool
  for a4: Bool
  for a5: Bool
  for b1: Bool
  for b2: Bool
  for b3: Bool
  for b4: Bool
  for b5: Bool
  {Bool.xor(div_cube(s, a1, a2, a3, a4, a5), div_cube(s, b1, b2, b3, b4, b5))
   == boundary_flux(a1, a2, a3, a4, a5, b1, b2, b3, b4, b5) : Bool}
