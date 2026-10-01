import Base

# ============================================================
# signed-core/Core.bend
#
# Shared verified core for signed linear combinations over exact
# integers: the reusable B^2=0 machinery consumed by the triangle
# and the two-square geometries.
#
# Imports ONLY Base (never LAWS.bend, never sibling playgrounds).
# Public contract is over EXACT integers (difference pairs Z);
# no modular substitution anywhere.
#
# Design notes (checker constraints, all empirical on bend 2.0.27):
# - No boolean reflection: from {Nat.is_eq(p,n)==True} nothing
#   propositional follows (no explosion from {False==True}).
#   Zero-denoting is therefore carried as SYNTACTIC (p,p) pairs,
#   via zscale_zero' below -- never via boolean hypotheses.
# - boundary COMBINES like terms (chinsert/chain_add), so that
#   double boundaries of closed tables compute to syntactic
#   (p,p) coefficients. An append-only boundary leaves uncombined
#   terms whose coefficients do not denote zero individually.
# - The reusable B^2 step is b2_step: the induction skeleton lives
#   in each geometry (a few lines), the substantive step here.
# ============================================================

# ============================================================
# Part 1: Nat lemmas (Base proves none of these)
# ============================================================

# LEMMA: n replaces Nat.add(n, 0n). Induction on n.
def nat_add_zero_r(+n: Nat) -> {n == Nat.add(n, 0n) : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_zero_r(p) : {1n+p == 1n+_ : Nat}
      {==}

# LEMMA: 1n+Nat.add(n,m) replaces Nat.add(n, 1n+m). Induction on n.
def nat_add_succ_r(+n: Nat, +m: Nat) -> {1n+Nat.add(n, m) == Nat.add(n, 1n+m) : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_succ_r(p, m) : {1n+(1n+Nat.add(p, m)) == 1n+_ : Nat}
      {==}

# LEMMA: Nat.add is commutative. Induction on a.
def nat_add_comm(+a: Nat, +b: Nat) -> {Nat.add(a, b) == Nat.add(b, a) : Nat}:
  match a:
    case 0n:
      %nat_add_zero_r(b) : {b == _ : Nat}
      {==}
    case 1n+p:
      %nat_add_succ_r(b, p) : {1n+Nat.add(p, b) == _ : Nat}
      %nat_add_comm(p, b) : {1n+Nat.add(p, b) == 1n+_ : Nat}
      {==}

# LEMMA: Nat.add is associative. Induction on a.
def nat_add_assoc(+a: Nat, +b: Nat, +c: Nat) -> {Nat.add(Nat.add(a, b), c) == Nat.add(a, Nat.add(b, c)) : Nat}:
  match a:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_assoc(p, b, c) : {1n+Nat.add(Nat.add(p, b), c) == 1n+_ : Nat}
      {==}

# LEMMA: Nat.is_eq is reflexive. Induction on n.
def nat_is_eq_refl(+n: Nat) -> {Nat.is_eq(n, n) == True{} : Bool}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      %nat_is_eq_refl(p) : {Nat.is_eq(1n+p, 1n+p) == _ : Bool}
      {==}

# ============================================================
# Part 2: Nat.mul theory (Base proves none of these).
# Nat.mul recurses on its FIRST argument.
# ============================================================

# LEMMA: Nat.mul(n, 0n) == 0n. Induction on n.
def nat_mul_zero_r(+n: Nat) -> {Nat.mul(n, 0n) == 0n : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      %Equal.sym(Nat, Nat.mul(p, 0n), 0n, nat_mul_zero_r(p)) : {Nat.add(0n, _) == 0n : Nat}
      {==}

# LEMMA: Nat.mul(n, 1n) == n. Induction on n.
def nat_mul_one_r(+n: Nat) -> {Nat.mul(n, 1n) == n : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      %Equal.sym(Nat, Nat.mul(p, 1n), p, nat_mul_one_r(p)) : {Nat.add(1n, _) == 1n+p : Nat}
      {==}

# ============================================================
# Part 3: exact integers as difference pairs (pos, neg)
# ============================================================

type Z is Data:
  ZC{ pos: Nat, neg: Nat }

def zzero() -> Z:
  ZC{ 0n, 0n }

def zone() -> Z:
  ZC{ 1n, 0n }

def zneg(x: Z) -> Z:
  match x:
    case ZC{+p, +n}:
      ZC{ n, p }

def zadd(x: Z, y: Z) -> Z:
  match x:
    case ZC{+xp, +xn}:
      match y:
        case ZC{+yp, +yn}:
          ZC{ Nat.add(xp, yp), Nat.add(xn, yn) }

def zsub(x: Z, y: Z) -> Z:
  zadd(x, zneg(y))

# Zero test: (p, n) denotes zero iff p == n. Decidable by computation.
def z_is_zero(x: Z) -> Bool:
  match x:
    case ZC{+p, +n}:
      Nat.is_eq(p, n)

# Integer multiplication on difference pairs.
def zmul(x: Z, y: Z) -> Z:
  match x:
    case ZC{+xp, +xn}:
      match y:
        case ZC{+yp, +yn}:
          ZC{ Nat.add(Nat.mul(xp, yp), Nat.mul(xn, yn)),
               Nat.add(Nat.mul(xp, yn), Nat.mul(xn, yp)) }

# LEMMA: zadd is commutative.
def zadd_comm(+x: Z, +y: Z) -> {zadd(x, y) == zadd(y, x) : Z}:
  match x:
    case ZC{+xp, +xn}:
      match y:
        case ZC{+yp, +yn}:
          %nat_add_comm(xp, yp) : {ZC{Nat.add(xp, yp), Nat.add(xn, yn)} == ZC{_, Nat.add(yn, xn)} : Z}
          %nat_add_comm(xn, yn) : {ZC{Nat.add(xp, yp), Nat.add(xn, yn)} == ZC{Nat.add(xp, yp), _} : Z}
          {==}

# LEMMA: zadd is associative.
def zadd_assoc(+x: Z, +y: Z, +z: Z) -> {zadd(zadd(x, y), z) == zadd(x, zadd(y, z)) : Z}:
  match x:
    case ZC{+xp, +xn}:
      match y:
        case ZC{+yp, +yn}:
          match z:
            case ZC{+zp, +zn}:
              %nat_add_assoc(xp, yp, zp) : {ZC{Nat.add(Nat.add(xp, yp), zp), Nat.add(Nat.add(xn, yn), zn)} == ZC{_, Nat.add(xn, Nat.add(yn, zn))} : Z}
              %nat_add_assoc(xn, yn, zn) : {ZC{Nat.add(Nat.add(xp, yp), zp), Nat.add(Nat.add(xn, yn), zn)} == ZC{Nat.add(Nat.add(xp, yp), zp), _} : Z}
              {==}

# LEMMA: zzero is a right unit.
def zadd_zero_r(+x: Z) -> {zadd(x, zzero()) == x : Z}:
  match x:
    case ZC{+p, +n}:
      %nat_add_zero_r(p) : {ZC{_, Nat.add(n, 0n)} == ZC{p, n} : Z}
      %nat_add_zero_r(n) : {ZC{p, _} == ZC{p, n} : Z}
      {==}

# LEMMA: double negation. Definitional (swap twice).
def zneg_invol(+x: Z) -> {zneg(zneg(x)) == x : Z}:
  match x:
    case ZC{+p, +n}:
      {==}

# LEMMA (cancellation): x + (-x) denotes zero.
def zadd_neg_zero(+x: Z) -> {z_is_zero(zadd(x, zneg(x))) == True{} : Bool}:
  match x:
    case ZC{+p, +n}:
      %nat_add_comm(p, n) : {Nat.is_eq(Nat.add(p, n), _) == True{} : Bool}
      %nat_is_eq_refl(Nat.add(p, n)) : {Nat.is_eq(Nat.add(p, n), Nat.add(p, n)) == _ : Bool}
      {==}

# LEMMA: zmul(x, zone) == x. Needs mul_one_r, mul_zero_r, add_zero_r.
def zmul_one_r(+x: Z) -> {zmul(x, zone()) == x : Z}:
  match x:
    case ZC{+p, +n}:
      %Equal.sym(Nat, Nat.mul(p, 1n), p, nat_mul_one_r(p)) : {ZC{Nat.add(_, Nat.mul(n, 0n)), Nat.add(Nat.mul(p, 0n), Nat.mul(n, 1n))} == ZC{p, n} : Z}
      %Equal.sym(Nat, Nat.mul(n, 0n), 0n, nat_mul_zero_r(n)) : {ZC{Nat.add(p, _), Nat.add(Nat.mul(p, 0n), Nat.mul(n, 1n))} == ZC{p, n} : Z}
      %nat_add_zero_r(p) : {ZC{_, Nat.add(Nat.mul(p, 0n), Nat.mul(n, 1n))} == ZC{p, n} : Z}
      %Equal.sym(Nat, Nat.mul(p, 0n), 0n, nat_mul_zero_r(p)) : {ZC{p, Nat.add(_, Nat.mul(n, 1n))} == ZC{p, n} : Z}
      %Equal.sym(Nat, Nat.mul(n, 1n), n, nat_mul_one_r(n)) : {ZC{p, _} == ZC{p, n} : Z}
      {==}

# LEMMA: zmul(a, zneg(zone)) == zneg(a).
def zmul_neg_one_r(+a: Z) -> {zmul(a, zneg(zone())) == zneg(a) : Z}:
  match a:
    case ZC{+p, +n}:
      # zmul((p,n),(0,1)) = (p*0+n*1, p*1+n*0); zneg((p,n)) = (n,p).
      %Equal.sym(Nat, Nat.mul(p, 0n), 0n, nat_mul_zero_r(p)) : {ZC{Nat.add(_, Nat.mul(n, 1n)), Nat.add(Nat.mul(p, 1n), Nat.mul(n, 0n))} == ZC{n, p} : Z}
      %Equal.sym(Nat, Nat.mul(n, 1n), n, nat_mul_one_r(n)) : {ZC{Nat.add(0n, _), Nat.add(Nat.mul(p, 1n), Nat.mul(n, 0n))} == ZC{n, p} : Z}
      %Equal.sym(Nat, Nat.mul(p, 1n), p, nat_mul_one_r(p)) : {ZC{n, Nat.add(_, Nat.mul(n, 0n))} == ZC{n, p} : Z}
      %Equal.sym(Nat, Nat.mul(n, 0n), 0n, nat_mul_zero_r(n)) : {ZC{n, Nat.add(p, _)} == ZC{n, p} : Z}
      %nat_add_zero_r(p) : {ZC{n, _} == ZC{n, p} : Z}
      {==}

# ============================================================
# Part 4: chains, tables, boundary
# ============================================================

# A chain is a finite signed linear combination: list of (cell, coeff).
type Chain is Data:
  CNil{}
  CCons{ cell: Nat, coeff: Z, rest: Chain }

# A table is finite incidence data: list of (cell, boundary-chain).
type Table is Data:
  TNil{}
  TCons{ cell: Nat, bnd: Chain, rest: Table }

# Lookup a cell's boundary chain (empty if absent).
# pick is non-recursive; lookup's self-call is the only recursion.
def pick(+eq: Bool, +b: Chain, +d: Chain) -> Chain:
  match eq:
    case True{}:
      b
    case False{}:
      d

def lookup(+t: Table, +cell: Nat) -> Chain:
  match t:
    case TNil{}:
      CNil{}
    case TCons{+c, +b, +rest}:
      pick(Nat.is_eq(c, cell), b, lookup(rest, cell))

# Scale a chain by a scalar (coefficient-wise zmul).
def chain_scale(+a: Z, +c: Chain) -> Chain:
  match c:
    case CNil{}:
      CNil{}
    case CCons{+cell, +x, +rest}:
      CCons{ cell, zmul(a, x), chain_scale(a, rest) }

# Insert, combining coefficients for an existing cell via zadd.
# (The recursive call is evaluated eagerly as pick's argument; correct
# but not lazy. Tables are tiny so this is fine.)
def chinsert(+cell: Nat, +x: Z, +c: Chain) -> Chain:
  match c:
    case CNil{}:
      CCons{ cell, x, CNil{} }
    case CCons{+c2, +y, +rest}:
      pick(Nat.is_eq(cell, c2),
           CCons{ c2, zadd(x, y), rest },
           CCons{ c2, y, chinsert(cell, x, rest) })

# Add two chains (union, combining like cells).
def chain_add(+c1: Chain, +c2: Chain) -> Chain:
  match c1:
    case CNil{}:
      c2
    case CCons{+cell, +x, +rest}:
      chinsert(cell, x, chain_add(rest, c2))

# Linear extension of the boundary: B(sum a_i [c_i]) = sum a_i B([c_i]).
# Combines like terms so closed double boundaries compute to
# syntactic (p,p) coefficients.
def boundary(+t: Table, +c: Chain) -> Chain:
  match c:
    case CNil{}:
      CNil{}
    case CCons{+cell, +a, +rest}:
      chain_add(chain_scale(a, lookup(t, cell)), boundary(t, rest))

# Decidable zero test on a chain (each coefficient denotes zero).
def chain_is_zero(+c: Chain) -> Bool:
  match c:
    case CNil{}:
      True{}
    case CCons{+cell, +x, +rest}:
      Bool.and(z_is_zero(x), chain_is_zero(rest))

# KEY LEMMA (no boolean reflection): scaling a syntactic (p,p) pair
# denotes zero. The pair (p,p) is manifestly zero-denoting; zmul
# preserves this by nat_is_eq_refl alone.
def zscale_zero_pp(+a: Z, +p: Nat) -> {z_is_zero(zmul(a, ZC{ p, p })) == True{} : Bool}:
  match a:
    case ZC{+ap, +an}:
      %nat_is_eq_refl(Nat.add(Nat.mul(ap, p), Nat.mul(an, p))) : {Nat.is_eq(Nat.add(Nat.mul(ap, p), Nat.mul(an, p)), Nat.add(Nat.mul(ap, p), Nat.mul(an, p))) == _ : Bool}
      {==}

# SIMPLIFICATION HELPERS (no associativity needed):
# zmul(zmul(a, +/-1), +/-1) reduces via zmul_one_r / zmul_neg_one_r.

# zmul(zmul(a,1),1) == a.
def zmul_zmul_11(+a: Z) -> {zmul(zmul(a, zone()), zone()) == a : Z}:
  # Rewrite inner zmul(a,1) to a (via sym), then outer zmul(a,1) to a.
  %Equal.sym(Z, zmul(a, zone()), a, zmul_one_r(a)) : {zmul(_, zone()) == a : Z}
  %Equal.sym(Z, zmul(a, zone()), a, zmul_one_r(a)) : {_ == a : Z}
  {==}

# zmul(zmul(a,1),-1) == zneg(a).
def zmul_zmul_1n(+a: Z) -> {zmul(zmul(a, zone()), zneg(zone())) == zneg(a) : Z}:
  %Equal.sym(Z, zmul(a, zone()), a, zmul_one_r(a)) : {zmul(_, zneg(zone())) == zneg(a) : Z}
  %Equal.sym(Z, zmul(a, zneg(zone())), zneg(a), zmul_neg_one_r(a)) : {_ == zneg(a) : Z}
  {==}

# zmul(zmul(a,-1),1) == zneg(a).
def zmul_zmul_n1(+a: Z) -> {zmul(zmul(a, zneg(zone())), zone()) == zneg(a) : Z}:
  %Equal.sym(Z, zmul(a, zneg(zone())), zneg(a), zmul_neg_one_r(a)) : {zmul(_, zone()) == zneg(a) : Z}
  %Equal.sym(Z, zmul(zneg(a), zone()), zneg(a), zmul_one_r(zneg(a))) : {_ == zneg(a) : Z}
  {==}

# zmul(zmul(a,-1),-1) == a.
def zmul_zmul_nn(+a: Z) -> {zmul(zmul(a, zneg(zone())), zneg(zone())) == a : Z}:
  %Equal.sym(Z, zmul(a, zneg(zone())), zneg(a), zmul_neg_one_r(a)) : {zmul(_, zneg(zone())) == a : Z}
  %Equal.sym(Z, zmul(zneg(a), zneg(zone())), zneg(zneg(a)), zmul_neg_one_r(zneg(a))) : {_ == a : Z}
  %Equal.sym(Z, zneg(zneg(a)), a, zneg_invol(a)) : {_ == a : Z}
  {==}
