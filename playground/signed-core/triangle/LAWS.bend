import Base
import ../Core.bend as C

# RED (Delivery 2): the triangle re-expressed through the shared core.
# Vertices {0,1,2}, edges {3=[01],4=[02],5=[12]}, face {6=[012]}.
# Incidence coefficients are exact integers (difference pairs).

def t_tri() -> C.Table:
  C.TCons{ 0n, C.CNil{},
  C.TCons{ 1n, C.CNil{},
  C.TCons{ 2n, C.CNil{},
  C.TCons{ 3n, C.CCons{1n, C.zone(), C.CCons{0n, C.zneg(C.zone()), C.CNil{}}},
  C.TCons{ 4n, C.CCons{2n, C.zone(), C.CCons{0n, C.zneg(C.zone()), C.CNil{}}},
  C.TCons{ 5n, C.CCons{2n, C.zone(), C.CCons{1n, C.zneg(C.zone()), C.CNil{}}},
  C.TCons{ 6n, C.CCons{5n, C.zone(), C.CCons{4n, C.zneg(C.zone()), C.CCons{3n, C.zone(), C.CNil{}}}},
  C.TNil{} } } } } } } }

# Per-cell certificate: B^2=0 on the basis cell, for ARBITRARY coefficient.
# Proved by finite case analysis on the cell id (7 cells).
law cell_closed:
  for cell: Nat
  for a: C.Z
  {C.chain_is_zero(C.boundary(t_tri(), C.chain_scale(a, C.lookup(t_tri(), cell)))) == True{} : Bool}

# The reusable B^2=0 theorem, instantiated for the triangle.
# Holds for arbitrary chains (arbitrary integer coefficients).
law b2:
  for c: C.Chain
  {C.chain_is_zero(C.boundary(t_tri(), C.boundary(t_tri(), c))) == True{} : Bool}
