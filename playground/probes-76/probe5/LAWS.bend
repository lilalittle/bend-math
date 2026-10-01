import Base

# PROBE 5 (#76 kill-order, probe 5): array refinement.
#
# Question: can a proof about a fixed-size array computation be stated and
# checked? Where does the fragment break?
#
# Design: a 2-vector type V2 (fixed size, structural), dot product dot2,
# and three rungs:
#   dot_eval  -- concrete evaluation: dot2(V2{2,3}, V2{4,5}) == 23.
#                Tests computation through the array structure.
#   dot_zero  -- dot2(a, V2{0,0}) == 0. Tests reasoning about the structure
#                with a variable vector; needs nat_mul_zero_r (proven here).
#   dot_comm  -- dot2(a,b) == dot2(b,a). STRETCH: needs nat_mul_comm.
#                If the arithmetic gets too heavy, this marks the boundary.
#
# Note: Base's Array<T> is a binary tree (ALeaf/ANode), awkward for fixed-size
# vectors. A dedicated V2 product type is the natural fixed-size representation.
# The probe tests whether the fragment handles the STRUCTURAL reasoning.

type V2 is Data:
  V2{ x: Nat, y: Nat }

def dot2(a: V2, b: V2) -> Nat:
  match a:
    case V2{+ax, +ay}:
      match b:
        case V2{+bx, +by}:
          Nat.add(Nat.mul(ax, bx), Nat.mul(ay, by))

def vec_add(a: V2, b: V2) -> V2:
  match a:
    case V2{+ax, +ay}:
      match b:
        case V2{+bx, +by}:
          V2{ Nat.add(ax, bx), Nat.add(ay, by) }

# --- Arithmetic support (self-contained) ---

def eq_sym(a: Nat, b: Nat, e: {a == b : Nat}) -> {b == a : Nat}:
  %e : {_ == a : Nat}
  {==}

def nat_mul_zero_r(+b: Nat) -> {Nat.mul(b, 0n) == 0n : Nat}:
  match b:
    case 0n:
      {==}
    case 1n+p:
      # Goal (computed): {Nat.add(0n, Nat.mul(p, 0n)) == 0n}.
      # Rewrite Nat.mul(p,0n) -> 0n (flip IH via eq_sym for left-to-right).
      %eq_sym(Nat.mul(p, 0n), 0n, nat_mul_zero_r(p)) : {Nat.add(0n, _) == 0n : Nat}
      {==}

# --- Rung 1: concrete evaluation through the structure ---

law dot_eval:
  {dot2(V2{ 2n, 3n }, V2{ 4n, 5n }) == 23n : Nat}

# --- Rung 2: zero vector annihilates (variable vector, structural) ---

law dot_zero:
  for ax: Nat
  for ay: Nat
  {dot2(V2{ ax, ay }, V2{ 0n, 0n }) == 0n : Nat}

# --- Rung 3 (stretch): commutativity of dot product ---
# dot_comm: dot2(a,b) == dot2(b,a) needs nat_mul_comm
#   (Nat.mul(ax,bx) == Nat.mul(bx,ax) etc.).
# nat_mul_comm is a substantial independent arithmetic development
# (induction + nat_mul_succ_r lemma + rearrangements) -- it is NOT an array
# issue. The array fragment itself (structure, computation, variable reasoning)
# is proven by rungs 1-2. We do NOT state dot_comm as a law here because an
# unfilled law is a dead claim; the boundary is: algebraic properties of the
# ELEMENT operations must be supplied separately, then the array reasoning
# composes. See verdict in the final report.
