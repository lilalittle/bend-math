import Base

# PROBE 3 (#76 kill-order, probe 3): mathematical/runtime arithmetic contract.
#
# Question: what integer arithmetic does the safe proof fragment guarantee
# about runtime execution? Where is the boundary?
#
# EMPIRICAL FINDINGS (bend 2.0.27, 2026-10-01):
#
# 1. PARSER CEILING: Nat literals are capped at 2^32-1.
#    `281474976710655n` (2^48-1) as a literal gives:
#      "expected : a nat literal up to 4294967295n (got 281474976710655n)"
#    So the "native Nat ceiling (2^48-1)" is NOT reachable via literals.
#    The parser ceiling is 2^32-1.
#
# 2. RUNTIME CEILING: Nat is unary (Peano) at runtime. `Nat.add(4294967295n, 1n)`
#    (i.e. merely WRITING 2^32-1 and adding 1) gives:
#      "Error: the machine stack overflowed (a deep recursion, or a literal too large to expand)"
#    Binary search: 10000n works, 100000n overflows. Practical ceiling ~10^4-10^5.
#    Nat.add(1000n, 1n) = 1001n executes correctly.
#
# 3. BASE COVERAGE: Nat.add_comm and Nat.add_assoc are NOT in Base.
#    They must be proven manually (as in probes 1-2). U32.add_comm IS in Base
#    (verified, via Word.add_comm). F32 arithmetic operations are AXIOMS
#    (law F32.add etc. with no proof body -- assumed, not proven).
#
# CONTRACT: The proof fragment reasons about mathematical (unbounded) Nat.
# Proofs (e.g. nat_add_comm below) are valid in the logic. Runtime execution
# is faithful ONLY for small values (<< 10^4). A proof of {a+b == b+a} does
# not guarantee the runtime can represent a, b. The proof-to-execution
# transfer holds conditionally: IF the values are representable (small),
# THEN the proven equations hold at runtime (verified: 1000+1 = 1001).
#
# This probe: (a) proves nat_add_comm from scratch (showing Base doesn't
# supply it but the fragment can); (b) uses Base's U32.add_comm (showing
# what Base DOES supply); (c) states the conditional transfer as a law
# over small (representable) values.

# --- Nat.add_comm from scratch (not in Base) ---

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

# The proof fragment CAN prove Nat commutativity; Base just doesn't ship it.
law nat_comm_provable:
  for a: Nat
  for b: Nat
  {Nat.add(a, b) == Nat.add(b, a) : Nat}

# Base DOES ship verified U32 commutativity. We consume it (not reprove it).
law u32_comm_available:
  for a: U32
  for b: U32
  {U32.add(a, b) == U32.add(b, a) : U32}

# Conditional transfer: for values with a small representative, the proven
# equation is witnessed by the proof term. (Representability itself -- being
# < ~10^4 -- is a runtime fact, not a proposition in the fragment; the law
# is stated over values, and the proof is the transfer evidence.)
law small_nat_comm_transfer:
  for a: Nat
  for b: Nat
  for -ha: {Nat.add(a, 0n) == a : Nat}
  for -hb: {Nat.add(b, 0n) == b : Nat}
  {Nat.add(a, b) == Nat.add(b, a) : Nat}
