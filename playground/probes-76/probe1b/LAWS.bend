import Base

# PROBE 1b (#76 correction, 2026-10-01): dependent-function evidence syntax.
#
# CORRECTION: probe 1 concluded "Bend cannot quantify over functions" from the
# parse failure of `for -h: (x: Nat) -> {f(x) == g(x)}`. That syntax was simply
# wrong. Bend 2.0.27 documents dependent function types as `@x: A -> B`
# (guide, type-grammar section), and Base ships `Equal.cong` with
# `for -f: A -> B` -- arbitrary-function quantification is present in the
# shipped source. This probe reopens ONLY the failed subprobe with the
# documented syntax, distinguishing parse / type / quantity / proof failures.
#
# Concrete pointwise-equal functions (top-level defs; f, g themselves are NOT
# the quantified thing here -- the EVIDENCE h is).
def f(n: Nat) -> Nat:
  Nat.add(n, 1n)

def g(n: Nat) -> Nat:
  Nat.add(1n, n)

# Rung 1: ONE application of dependent pointwise evidence, ordinary binder.
# RESULT (2026-10-01, bend 2.0.27): CHECKS. Parses, typechecks, proves.
law one_app:
  for h: (@x: Nat -> {f(x) == g(x) : Nat})
  {f(0n) == g(0n) : Nat}

# Rung 2: REPEATED evidence use via template binder.
# RESULT: CHECKS. `~h` may be applied at as many indices as needed.
law two_apps_tmpl:
  for ~h: (@x: Nat -> {f(x) == g(x) : Nat})
  {Nat.add(f(0n), f(1n)) == Nat.add(g(0n), g(1n)) : Nat}

# --- NEGATIVE RESULTS (exact reproducers; these do NOT check) ---
#
# (a) Plain `h` applied twice -- QUANTITY failure (not parse, not type):
#     law two_apps:
#       for h: (@x: Nat -> {f(x) == g(x) : Nat})
#       {Nat.add(f(0n), f(1n)) == Nat.add(g(0n), g(1n)) : Nat}
#     proof attempt `% h(0n) : ...` then `%h(1n) : ...` gives:
#       "expected : h / observed : h (consumed more than once)"
#     Functions are affine; a plain hypothesis function is single-use.
#
# (b) Copyable `+h` -- KIND failure:
#       for +h: (@x: Nat -> {f(x) == g(x) : Nat})
#     gives: "expected : Data / observed : Type".
#     `+` requires Data; function types are Type. There is no `+` for functions.
#
# (c) Erased `-h` APPLIED as evidence -- ERASURE failure:
#       for -h: (@x: Nat -> {f(x) == g(x) : Nat})
#     The binder itself parses, typechecks, and fills (cf. erased_plain_fn
#     control below). But using it as a proof term -- `h(0n)` directly or
#     `% h(0n) : ...` in a rewrite -- gives:
#       "expected : -h / observed : h"
#     An erased function can appear in type/template positions (as Base's
#     `Equal.cong` does with its `-f`), but cannot be APPLIED to produce
#     evidence, because application requires computing the erased value.
#     Control: `for -h: (Nat -> Nat)` with proof `{==}` (h never applied)
#     fills and checks fine -- so the failure is in application, not binding.
law erased_plain_fn:
  for -h: (Nat -> Nat)
  {f(0n) == g(0n) : Nat}
