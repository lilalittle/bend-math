import Base
import ./Algebra.bend as Alg

# RED (bend-packages#67 signed milestone): signed chains on the triangle.
#
# The F2-only proofs (d2-zero, vector-identities) cannot see orientation-sign
# errors: modulo two, a flipped incidence sign is invisible. This slice
# replaces the F2 foundation with signed chains over exact integers for the
# smallest diagnostic -- the triangle -- plus two controls:
#   (a) consistent reorientation preserves the identity over the integers;
#   (b) an inconsistent incidence mutant yields a checked nonzero residual;
#   (c) reducing that SAME signed construction mod 2 conceals the defect.
# (c) is proved by applying the mod-2 reduction map to the same signed
# chain b1(b2_bad) -- not by a separately implemented Boolean example --
# so the connection between the signed construction and its mod-2 shadow
# is established, not assumed.
#
# REFACTOR: the integer arithmetic now lives in Algebra.bend, which imports
# only Base -- the dependency points from this spec into the algebra, not
# the reverse (adversarial-review #7). Equality of Z representatives is NOT
# integer equality, so laws about chains go through the decidable zero test
# Alg.z_is_zero, never bare syntactic equality of Z terms (except the
# mutant's exact-residual law, whose both sides are closed terms that
# compute to the same pair).

# ---- The triangle complex ----
# Vertices {0,1,2}, oriented edges {01,02,12}, one face [012].
# Coefficients in Alg.Z (exact integers as difference pairs).

type VChain is Data:
  VC{ c0: Alg.Z, c1: Alg.Z, c2: Alg.Z }

type EChain is Data:
  EC{ e01: Alg.Z, e02: Alg.Z, e12: Alg.Z }

# Boundary of the face: d[012] = [12] - [02] + [01].
# Edge order in EC is (01, 02, 12).
def b2() -> EChain:
  EC{ Alg.zone, Alg.zneg(Alg.zone), Alg.zone }

# Boundary of a 1-chain: d[ij] = [j] - [i], linearly extended.
# v0 = -e01 - e02, v1 = e01 - e12, v2 = e02 + e12.
def b1(e: EChain) -> VChain:
  match e:
    case EC{+a, +b, +c}:
      VC{ Alg.zadd(Alg.zneg(a), Alg.zneg(b)), Alg.zadd(a, Alg.zneg(c)), Alg.zadd(b, c) }

def vchain_is_zero(v: VChain) -> Bool:
  match v:
    case VC{+x, +y, +z}:
      Bool.and(Alg.z_is_zero(x), Bool.and(Alg.z_is_zero(y), Alg.z_is_zero(z)))

# All three coefficients even (zero mod 2).
def vchain_parity_zero(v: VChain) -> Bool:
  match v:
    case VC{+x, +y, +z}:
      Bool.and(Bool.not(Alg.z_parity(x)),
        Bool.and(Bool.not(Alg.z_parity(y)), Bool.not(Alg.z_parity(z))))

# The inconsistent mutant: d_bad[012] = [12] + [02] + [01].
# One incidence coefficient flipped WITHOUT the consistency changes a
# genuine reorientation would require. Must stay well-typed.
def b2_bad() -> EChain:
  EC{ Alg.zone, Alg.zone, Alg.zone }

# Reoriented complex, CONSISTENTLY updated: edge 01 becomes 10 with
# d[10] = [0] - [1] = -d[01]. The face boundary becomes
# [12] - [02] - [10], and the 1-boundary's first column is negated:
# v0 = e10 - e02, v1 = -e10 - e12, v2 = e02 + e12.
def b2_re() -> EChain:
  EC{ Alg.zneg(Alg.zone), Alg.zneg(Alg.zone), Alg.zone }

def b1_re(e: EChain) -> VChain:
  match e:
    case EC{+a, +b, +c}:
      VC{ Alg.zadd(a, Alg.zneg(b)), Alg.zadd(Alg.zneg(a), Alg.zneg(c)), Alg.zadd(b, c) }

# (a) Consistent reorientation preserves d^2 = 0 over the integers.
law boundary_squared_zero:
  {vchain_is_zero(b1(b2)) == True{} : Bool}

law reorient_consistent:
  {vchain_is_zero(b1_re(b2_re)) == True{} : Bool}

# (b) The mutant's exact residual: d1 d_bad[012] = 2[2] - 2[0].
# Coefficients (c0, c1, c2) = (-2, 0, +2), i.e. (0,2), (1,1), (2,0) as pairs.
law mutant_residual_exact:
  {b1(b2_bad) == VC{ Alg.ZC{0n, 2n}, Alg.ZC{1n, 1n}, Alg.ZC{2n, 0n} } : VChain}

# (b) continued: checked nonzero-residual witness. Well-typed, no timeout,
# no missing proof -- the checker confirms the residual is nonzero.
law mutant_residual_nonzero:
  {vchain_is_zero(b1(b2_bad)) == False{} : Bool}

# (c) Reducing the SAME signed construction mod 2 conceals the defect:
# the mutant's residual, nonzero over Z, is zero in the mod-2 shadow.
law mutant_vanishes_mod2:
  {vchain_parity_zero(b1(b2_bad)) == True{} : Bool}
