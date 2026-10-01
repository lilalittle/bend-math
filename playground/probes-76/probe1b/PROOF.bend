import Base
import ./LAWS.bend as Laws

# Rung 1: one application of dependent evidence. The proof term IS h(0n).
def Laws.one_app(h):
  h(0n)

# Rung 2: template evidence applied at two indices, driving two rewrites.
# (Second and later `%` take no space; `_` marks the RHS occurrence.)
def Laws.two_apps_tmpl(h):
  % h(0n) : {Nat.add(Laws.f(0n), Laws.f(1n)) == Nat.add(_, Laws.g(1n)) : Nat}
  %h(1n) : {Nat.add(Laws.f(0n), Laws.f(1n)) == Nat.add(Laws.f(0n), _) : Nat}
  {==}

# Control: erased non-dependent function hypothesis, never applied.
def Laws.erased_plain_fn(h):
  {==}
