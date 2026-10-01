import Base
import ./LAWS.bend as Laws

# GREEN: all five laws hold by checked computation (normalization).
# No case-splitting over assignments anywhere: each goal is a closed term
# that the checker reduces. The algebraic content lives in the zero test
# (the pair (1,1) denoting 1 - 1 = 0, decided by Nat.is_eq) and, after the
# REFACTOR split, in the structurally proved Z group laws in Algebra.bend.

# (a) d^2 = 0 on the triangle, over the integers. b1(b2) computes to
# ((1,1),(1,1),(1,1)) and each pair passes the zero test.
def Laws.boundary_squared_zero():
  {==}

# (a) control: consistently reorienting edge 01 -> 10 (negating both the
# face coefficient and the 1-boundary's first column) preserves d^2 = 0.
def Laws.reorient_consistent():
  {==}

# (b) the mutant's exact residual, computed: d1 d_bad[012] = 2[2] - 2[0].
def Laws.mutant_residual_exact():
  {==}

# (b) checked nonzero-residual witness: the residual is NOT the zero chain.
def Laws.mutant_residual_nonzero():
  {==}

# (c) the mod-2 shadow of the SAME signed chain: reducing b1(b2_bad)
# coefficient-wise mod 2 gives zero -- the defect is concealed mod 2.
def Laws.mutant_vanishes_mod2():
  {==}
