import Base

# REFACTOR (bend-packages#67 signed milestone): exact integer arithmetic,
# standalone.
#
# DEPENDENCY DIRECTION (adversarial-review #7): this module imports ONLY
# Base -- never LAWS.bend. The playground spec (LAWS.bend) imports this
# algebra, not the reverse. The triangle complex in LAWS.bend is this
# algebra's first consumer; the second geometry (next delivery) must
# consume these same definitions and lemmas without copying proof code.
#
# Integers are difference pairs (pos, neg) denoting pos - neg -- the same
# num/den pair pattern as playground/units. Equality of representatives
# is NOT integer equality, so cancellation is stated through the
# decidable zero test z_is_zero (zadd_neg_zero below), proved by
# structural induction, not by enumerating assignments.

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
# Part 2: exact integers as difference pairs
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

def nat_parity(n: Nat) -> Bool:
  match n:
    case 0n:
      False{}
    case 1n+m:
      Bool.not(nat_parity(m))

# Mod-2 reduction on coefficients: parity(p - n) = parity(p) XOR parity(n),
# since -n is congruent to n mod 2. The shadow map to F2 chains.
def z_parity(x: Z) -> Bool:
  match x:
    case ZC{+p, +n}:
      Bool.xor(nat_parity(p), nat_parity(n))

# ============================================================
# Part 3: Z group laws, proved structurally (no enumeration)
# ============================================================

# LEMMA: zadd is commutative. Destructure; rewrite each component
# backwards with nat_add_comm.
def zadd_comm(+x: Z, +y: Z) -> {zadd(x, y) == zadd(y, x) : Z}:
  match x:
    case ZC{+xp, +xn}:
      match y:
        case ZC{+yp, +yn}:
          %nat_add_comm(xp, yp) : {ZC{Nat.add(xp, yp), Nat.add(xn, yn)} == ZC{_, Nat.add(yn, xn)} : Z}
          %nat_add_comm(xn, yn) : {ZC{Nat.add(xp, yp), Nat.add(xn, yn)} == ZC{Nat.add(xp, yp), _} : Z}
          {==}

# LEMMA: zadd is associative. Destructure; rewrite each component
# backwards with nat_add_assoc.
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

# LEMMA (cancellation): x + (-x) denotes zero. The pair computes to
# (p+n, n+p); nat_add_comm aligns the components; is_eq is reflexive.
def zadd_neg_zero(+x: Z) -> {z_is_zero(zadd(x, zneg(x))) == True{} : Bool}:
  match x:
    case ZC{+p, +n}:
      %nat_add_comm(p, n) : {Nat.is_eq(Nat.add(p, n), _) == True{} : Bool}
      %nat_is_eq_refl(Nat.add(p, n)) : {Nat.is_eq(Nat.add(p, n), Nat.add(p, n)) == _ : Bool}
      {==}
