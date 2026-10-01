import Base
import ../signed-core/Core.bend as C

# ============================================================
# signed-core-v2/Core2.bend
#
# Option A redesign: NON-COMBINING (linear/append) boundary +
# syntactic normalization via ZeroChain.
#
# Design (checker constraints, bend 2.0.27):
# - boundary uses chain_append (provably linear via boundary_append).
# - ZeroChain carries manifestly (p,p) coefficients. zchain_append
#   is non-combining; (p,p) is preserved by construction.
#   zchain_is_zero needs no boolean reflection (nat_is_eq_refl).
# - b2z builds the certified double boundary from per-cell
#   ZeroChain certificates (geometry provides them, combined).
# - The universal theorem (LAWS.bend) quantifies over t: Table
#   and c: Chain (finite data). The per-cell certificate is a
#   first-order dependent function over Nat/Z data (NOT a
#   higher-order operator); probe1b showed @x/~ binders work.
# ============================================================

# Non-combining append on chains.
def chain_append(+c1: C.Chain, +c2: C.Chain) -> C.Chain:
  match c1:
    case C.CNil{}:
      c2
    case C.CCons{+cell, +x, +rest}:
      C.CCons{ cell, x, chain_append(rest, c2) }

# LEMMA: chain_append is associative. Induction on x.
def chain_append_assoc(+x: C.Chain, +y: C.Chain, +z: C.Chain)
  -> {chain_append(chain_append(x, y), z) == chain_append(x, chain_append(y, z)) : C.Chain}:
  match x:
    case C.CNil{}:
      {==}
    case C.CCons{+cell, +a, +rest}:
      %chain_append_assoc(rest, y, z) : {C.CCons{cell, a, chain_append(chain_append(rest, y), z)} == C.CCons{cell, a, _} : C.Chain}
      {==}

# ZeroChain: chains with manifestly (p,p) coefficients.
type ZeroChain is Data:
  ZNil{}
  ZCons{ cell: Nat, pos: Nat, rest: ZeroChain }

def to_chain(+z: ZeroChain) -> C.Chain:
  match z:
    case ZNil{}:
      C.CNil{}
    case ZCons{+cell, +p, +rest}:
      C.CCons{ cell, C.ZC{ p, p }, to_chain(rest) }

# Non-combining append on ZeroChains (preserves (p,p) trivially).
def zchain_append(+p: ZeroChain, +q: ZeroChain) -> ZeroChain:
  match p:
    case ZNil{}:
      q
    case ZCons{+cell, +pos, +rest}:
      ZCons{ cell, pos, zchain_append(rest, q) }

# LEMMA: to_chain distributes over zchain_append. Induction on p.
def to_chain_append(+p: ZeroChain, +q: ZeroChain)
  -> {to_chain(zchain_append(p, q)) == chain_append(to_chain(p), to_chain(q)) : C.Chain}:
  match p:
    case ZNil{}:
      {==}
    case ZCons{+cell, +pos, +rest}:
      %to_chain_append(rest, q) : {C.CCons{cell, C.ZC{pos, pos}, to_chain(zchain_append(rest, q))} == C.CCons{cell, C.ZC{pos, pos}, _} : C.Chain}
      {==}

# Wrapper: flipped nat_is_eq_refl (for right-to-left %).
def w_nat_is_eq_refl(+p: Nat) -> {True{} == Nat.is_eq(p, p) : Bool}:
  Equal.sym(Bool, Nat.is_eq(p, p), True{}, C.nat_is_eq_refl(p))

# KEY LEMMA (no boolean reflection): every ZeroChain denotes zero.
# Uses nat_is_eq_refl on the syntactic (p,p); induction on z.
def zchain_is_zero(+z: ZeroChain) -> {C.chain_is_zero(to_chain(z)) == True{} : Bool}:
  match z:
    case ZNil{}:
      {==}
    case ZCons{+cell, +p, +rest}:
      %w_nat_is_eq_refl(p) : {Bool.and(_, C.chain_is_zero(to_chain(rest))) == True{} : Bool}
      %Equal.sym(Bool, C.chain_is_zero(to_chain(rest)), True{}, zchain_is_zero(rest)) : {Bool.and(True{}, _) == True{} : Bool}
      {==}

# Linear boundary: B(sum a_i [c_i]) = append of a_i * B([c_i]).
# Uses chain_append (NOT chain_add), so it is provably linear.
def boundary(+t: C.Table, +c: C.Chain) -> C.Chain:
  match c:
    case C.CNil{}:
      C.CNil{}
    case C.CCons{+cell, +a, +rest}:
      chain_append(C.chain_scale(a, C.lookup(t, cell)), boundary(t, rest))

# LEMMA: boundary is linear over chain_append. Induction on c1.
# Needs chain_append_assoc to reassociate.
def boundary_append(+t: C.Table, +c1: C.Chain, +c2: C.Chain)
  -> {boundary(t, chain_append(c1, c2)) == chain_append(boundary(t, c1), boundary(t, c2)) : C.Chain}:
  match c1:
    case C.CNil{}:
      {==}
    case C.CCons{+cell, +a, +rest}:
      %Equal.sym(C.Chain, boundary(t, chain_append(rest, c2)), chain_append(boundary(t, rest), boundary(t, c2)), boundary_append(t, rest, c2)) : {chain_append(C.chain_scale(a, C.lookup(t, cell)), _) == chain_append(chain_append(C.chain_scale(a, C.lookup(t, cell)), boundary(t, rest)), boundary(t, c2)) : C.Chain}
      %chain_append_assoc(C.chain_scale(a, C.lookup(t, cell)), boundary(t, rest), boundary(t, c2)) : {_ == chain_append(chain_append(C.chain_scale(a, C.lookup(t, cell)), boundary(t, rest)), boundary(t, c2)) : C.Chain}
      {==}

# Double boundary (linear).
def b2(+t: C.Table, +c: C.Chain) -> C.Chain:
  boundary(t, boundary(t, c))

# Combining normalizer (chinsert fold). Used in the certificate
# correctness statement to relate to the linear b2.
def chnorm(+c: C.Chain) -> C.Chain:
  match c:
    case C.CNil{}:
      C.CNil{}
    case C.CCons{+cell, +x, +rest}:
      C.chinsert(cell, x, chnorm(rest))

# Singleton chain.
def single(+cell: Nat, +a: C.Z) -> C.Chain:
  C.CCons{ cell, a, C.CNil{} }

# Certified double boundary: builds a ZeroChain from per-cell
# certificates. cell_zc is the geometry-provided per-cell
# normalized double boundary (a first-order function on data).
def b2z(~cell_zc: (@cell: Nat -> @a: C.Z -> ZeroChain), +c: C.Chain) -> ZeroChain:
  match c:
    case C.CNil{}:
      ZNil{}
    case C.CCons{+cell, +a, +rest}:
      zchain_append(cell_zc(cell, a), b2z(cell_zc, rest))
