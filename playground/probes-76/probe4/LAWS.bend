import Base

# PROBE 4 (#76 kill-order, probe 4): generic algebra + repeated field evaluation.
#
# Question: can a generic algebraic identity be proven ONCE and applied at
# MULTIPLE concrete instantiations without copying proof code?
#
# SCOPE: "Generic" here means: one proof of distributivity for Nat.mul/Nat.add,
# applied at several concrete points. Full abstraction over arbitrary (add, mul)
# pairs is BLOCKED by probe 1's finding (no quantification over functions).
# The probe tests whether the single-proof/multiple-use pattern works within
# the ~-template + concrete-function discipline.
#
# The identity: Nat.mul(a, Nat.add(b, c)) == Nat.add(Nat.mul(a, b), Nat.mul(a, c)).
# Proven once by induction on a (nat_distr). Then instantiated at (2,3,4) and
# (5,6,7) with NO proof-code duplication -- the law fillers just apply nat_distr.

# --- Nat lemmas (self-contained) ---

def nat_add_zero_r(+n: Nat) -> {n == Nat.add(n, 0n) : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_zero_r(p) : {1n+p == 1n+_ : Nat}
      {==}

def nat_add_succ_r(+n: Nat, +m: Nat) -> {1n+Nat.add(n, m) == Nat.add(n, 1n+m) : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_succ_r(p, m) : {1n+(1n+Nat.add(p, m)) == 1n+_ : Nat}
      {==}

def nat_add_comm(+a: Nat, +b: Nat) -> {Nat.add(a, b) == Nat.add(b, a) : Nat}:
  match a:
    case 0n:
      %nat_add_zero_r(b) : {b == _ : Nat}
      {==}
    case 1n+p:
      %nat_add_succ_r(b, p) : {1n+Nat.add(p, b) == _ : Nat}
      %nat_add_comm(p, b) : {1n+Nat.add(p, b) == 1n+_ : Nat}
      {==}

def nat_add_assoc(+a: Nat, +b: Nat, +c: Nat) -> {Nat.add(Nat.add(a, b), c) == Nat.add(a, Nat.add(b, c)) : Nat}:
  match a:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_assoc(p, b, c) : {1n+Nat.add(Nat.add(p, b), c) == 1n+_ : Nat}
      {==}

def eq_sym(a: Nat, b: Nat, e: {a == b : Nat}) -> {b == a : Nat}:
  %e : {_ == a : Nat}
  {==}

def nat_add_assoc_sym(+a: Nat, +b: Nat, +c: Nat) -> {Nat.add(a, Nat.add(b, c)) == Nat.add(Nat.add(a, b), c) : Nat}:
  eq_sym(Nat.add(Nat.add(a, b), c), Nat.add(a, Nat.add(b, c)), nat_add_assoc(a, b, c))

def nat_add_comm_sym(+a: Nat, +b: Nat) -> {Nat.add(b, a) == Nat.add(a, b) : Nat}:
  eq_sym(Nat.add(a, b), Nat.add(b, a), nat_add_comm(a, b))

def add_rearr(+a: Nat, +b: Nat, +c: Nat, +d: Nat) -> {Nat.add(Nat.add(a, b), Nat.add(c, d)) == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}:
  %nat_add_assoc_sym(a, b, Nat.add(c, d)) : {_ == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  %nat_add_assoc(b, c, d) : {Nat.add(a, _) == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  %nat_add_comm_sym(b, c) : {Nat.add(a, Nat.add(_, d)) == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  %nat_add_assoc_sym(c, b, d) : {Nat.add(a, _) == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  %nat_add_assoc(a, c, Nat.add(b, d)) : {_ == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  {==}

# Step lemma (defined BEFORE nat_distr: no forward references).
# From the IH, derive the successor case.
# After computation, goal is:
#   (b+c)+Nat.mul(p,b+c) == (b+Nat.mul(p,b))+(c+Nat.mul(p,c))
# IH: Nat.mul(p,b+c) == Nat.mul(p,b)+Nat.mul(p,c).
def distr_step(+p: Nat, +b: Nat, +c: Nat, ih: {Nat.mul(p, Nat.add(b, c)) == Nat.add(Nat.mul(p, b), Nat.mul(p, c)) : Nat}) -> {Nat.mul(1n+p, Nat.add(b, c)) == Nat.add(Nat.mul(1n+p, b), Nat.mul(1n+p, c)) : Nat}:
  %eq_sym(Nat.mul(p, Nat.add(b, c)), Nat.add(Nat.mul(p, b), Nat.mul(p, c)), ih) : {Nat.add(Nat.add(b, c), _) == Nat.add(Nat.add(b, Nat.mul(p, b)), Nat.add(c, Nat.mul(p, c))) : Nat}
  %eq_sym(Nat.add(Nat.add(b, c), Nat.add(Nat.mul(p, b), Nat.mul(p, c))), Nat.add(Nat.add(b, Nat.mul(p, b)), Nat.add(c, Nat.mul(p, c))), add_rearr(b, c, Nat.mul(p, b), Nat.mul(p, c))) : {_ == Nat.add(Nat.add(b, Nat.mul(p, b)), Nat.add(c, Nat.mul(p, c))) : Nat}
  {==}

# THE generic identity, proven once by induction on a.
# Base case: Nat.mul(0, b+c) = 0 = Nat.mul(0,b) + Nat.mul(0,c) by computation.
# Step case: uses IH (nat_distr(p,b,c)) and add_rearr via distr_step.
def nat_distr(+a: Nat, +b: Nat, +c: Nat) -> {Nat.mul(a, Nat.add(b, c)) == Nat.add(Nat.mul(a, b), Nat.mul(a, c)) : Nat}:
  match a:
    case 0n:
      {==}
    case 1n+p:
      distr_step(p, b, c, nat_distr(p, b, c))

# --- Repeated instantiation: NO proof code copied, just apply nat_distr ---

law distr_inst1:
  {Nat.mul(2n, Nat.add(3n, 4n)) == Nat.add(Nat.mul(2n, 3n), Nat.mul(2n, 4n)) : Nat}

law distr_inst2:
  {Nat.mul(5n, Nat.add(6n, 7n)) == Nat.add(Nat.mul(5n, 6n), Nat.mul(5n, 7n)) : Nat}

law distr_inst3:
  for x: Nat
  {Nat.mul(x, Nat.add(1n, 1n)) == Nat.add(Nat.mul(x, 1n), Nat.mul(x, 1n)) : Nat}
