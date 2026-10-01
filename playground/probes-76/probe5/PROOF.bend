import Base
import ./LAWS.bend as Laws

# Rung 1: concrete evaluation. dot2(V2{2,3}, V2{4,5}) computes:
#   Nat.add(Nat.mul(2,4), Nat.mul(3,5)) = Nat.add(8, 15) = 23.
# The proof is by computation ({==} after normalization).
def Laws.dot_eval():
  {==}

# Unqualified wrappers for % rewrites (% needs a bare defined name).
def mul_zero_r(+b: Nat) -> {Nat.mul(b, 0n) == 0n : Nat}:
  Laws.nat_mul_zero_r(b)

def mul_zero_r_sym(a: Nat, b: {Nat.mul(a, 0n) == 0n : Nat}) -> {0n == Nat.mul(a, 0n) : Nat}:
  Laws.eq_sym(Nat.mul(a, 0n), 0n, b)

# Rung 2: zero vector. dot2(V2{ax,ay}, V2{0,0}) computes to
#   Nat.add(Nat.mul(ax,0), Nat.mul(ay,0)).
# Rewrite each Nat.mul(_,0) to 0 (flip via eq_sym for left-to-right),
# then Nat.add(0,0) == 0 by computation.
def dot_zero_go(+ax: Nat, +ay: Nat) -> {Laws.dot2(Laws.V2{ ax, ay }, Laws.V2{ 0n, 0n }) == 0n : Nat}:
  %mul_zero_r_sym(ax, mul_zero_r(ax)) : {Nat.add(_, Nat.mul(ay, 0n)) == 0n : Nat}
  %mul_zero_r_sym(ay, mul_zero_r(ay)) : {Nat.add(0n, _) == 0n : Nat}
  {==}

def Laws.dot_zero(ax, ay):
  dot_zero_go(ax, ay)
