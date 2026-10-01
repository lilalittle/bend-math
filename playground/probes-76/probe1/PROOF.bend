import Base
import ./LAWS.bend as Laws

# Rung 1: the hypothesis IS the proof.
def Laws.hyp_id(a, b, e):
  e

# Rung 2: the hypothesis drives a rewrite (right-to-left: b becomes a).
def Laws.hyp_rewrite(a, b, c, e):
  %e : {Nat.add(a, c) == Nat.add(_, c) : Nat}
  {==}

# Helper: congruence of Nat.add in the right argument, from a hypothesis.
# (Avoids a second % rewrite in the induction step.)
def add_congr_r(a: Nat, b: Nat, c: Nat, e: {b == c : Nat}) -> {Nat.add(a, b) == Nat.add(a, c) : Nat}:
  %e : {Nat.add(a, b) == Nat.add(a, _) : Nat}
  {==}

# Wrapper: the pointwise evidence at index m.
def h_at(m: Nat) -> {Laws.f(m) == Laws.g(m) : Nat}:
  Laws.h(m)

# Rung 3: induction on n. Each step reuses f, g (through ~ templates) and
# applies the evidence generator h at the new index, plus the IH.
def sum_congr_go(n: Nat) -> {Laws.sum_n(~Laws.f, n) == Laws.sum_n(~Laws.g, n) : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+(+m):
      % sum_congr_go(m) : {Nat.add(Laws.sum_n(~Laws.f, m), Laws.f(m)) == Nat.add(_, Laws.g(m)) : Nat}
      add_congr_r(Laws.sum_n(~Laws.f, m), Laws.f(m), Laws.g(m), h_at(m))

def Laws.sum_congr(n):
  sum_congr_go(n)
