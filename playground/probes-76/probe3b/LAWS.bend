import Base

# PROBE 3b (#76 correction, 2026-10-01): isolate the Nat failure phase.
#
# CORRECTION: probe 3 concluded "Nat is unary, therefore executable work must
# not use Nat" and "execution is faithful only for small values". That
# conflated four layers: logical representation, checker reduction, compiler
# lowering, and algorithm behavior. The discriminating experiments below
# (full transcript in TRANSCRIPT.md) localize the observed stack overflow.
#
# PINNED-SOURCE FACTS (bend 2.0.27):
# - Nat is logically Zero/Succ (base.bend).
# - Nat literals cap at 4294967295n; literals > 256n use U32.to_nat underneath
#   (guide). This is a literal-input rule, not a runtime-range specification.
# - Base's Nat.add is defined by NON-TAIL recursion on its first argument:
#     def Nat.add(a: Nat, b: Nat) -> Nat:
#       match a:
#         case 0n: b
#         case 1n+p: 1n+Nat.add(p, b)
#   (base.bend line 545). All Nat.* arithmetic in Base is similarly recursive;
#   no primitive Nat operations are visible in base.bend.
#
# LOCALIZED FINDING: the stack overflow is a property of non-tail recursion
# depth in Base's Nat.add definition, reached at runtime between 5000 and
# 10000 frames. It is NOT a property of Nat values, literals, formatting,
# or checker normalization -- all of which handle large values fine.
#
# The two laws below are CHECKED: the checker normalizes Nat.add at 1000 and
# 10000 steps. (The RUNTIME overflows on the 10000-step case -- see transcript.
# Checker and runtime have different reduction limits.)

law checker_add_1k:
  {Nat.add(1000n, 1n) == 1001n : Nat}

law checker_add_10k:
  {Nat.add(10000n, 1n) == 10001n : Nat}
