import Base

# PROBE 1 (#76 kill-order, probe 1): reusable quantified evidence.
#
# RED-phase feasibility probe. Question: can Bend 2.0.27's proof fragment
# support a reusable, extensional mathematical argument -- here, congruence
# of finite sums under pointwise equality -- where the SAME functions f, g
# and the SAME pointwise-evidence hypothesis h are used repeatedly
# (once per index) in erased proof positions?
#
# Ladder (each rung is a separate law so failures are granular):
#   hyp_id      -- a proof hypothesis used directly as the proof term.
#   hyp_rewrite -- a proof hypothesis used inside a % rewrite.
#   sum_congr   -- induction over n, reusing f, g at every step and
#                  applying the pointwise evidence h at each index.
#
# SCOPE NOTE (compiler limitation, isolated 2026-10-01): the direct
# formulation -- quantifying over ARBITRARY f, g with a dependent
# hypothesis `for -h: (x: Nat) -> {f(x) == g(x) : Nat}` -- does NOT parse:
# "expected: a defined name, observed: x". Bend 2.0.27 `for` binders cannot
# express dependent function types. So the generality (arbitrary functions
# + dependent evidence) is blocked at the type-expression level.
#   sum_congr therefore tests the MECHANISM with concrete top-level
# functions f, g and a concrete evidence generator h: induction reusing
# both functions and applying h at every index, all in proof positions.
# If even this fails, the block is in the mechanism, not just the binder.

law hyp_id:
  for -a: Nat
  for -b: Nat
  for e: {a == b : Nat}
  {a == b : Nat}

law hyp_rewrite:
  for -a: Nat
  for -b: Nat
  for -c: Nat
  for e: {a == b : Nat}
  {Nat.add(a, c) == Nat.add(b, c) : Nat}

# --- concrete pointwise-equal functions (top-level defs) ---
def f(n: Nat) -> Nat:
  Nat.add(n, 1n)

def g(n: Nat) -> Nat:
  Nat.add(1n, n)

# Nat addition lemmas (copied from signed-chains Algebra.bend; this probe
# is self-contained and must not modify the existing playground).
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

# Pointwise evidence as a top-level def: no dependent binder needed.
def h(x: Nat) -> {f(x) == g(x) : Nat}:
  nat_add_comm(x, 1n)

# Finite sum. ~f is a template: the guide states functions are Type
# (affine) and can never be copied, while a template "may be called as
# many times as you like".
def sum_n(~f: Nat -> Nat, n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+(+m):
      Nat.add(sum_n(~f, m), f(m))

law sum_congr:
  for n: Nat
  {sum_n(~f, n) == sum_n(~g, n) : Nat}
