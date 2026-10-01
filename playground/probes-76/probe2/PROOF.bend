import Base
import ./LAWS.bend as Laws

# ---- Nat lemmas (verbatim from probe1/LAWS.bend) ----

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


def nat_add_assoc(+a: Nat, +b: Nat, +c: Nat) -> {Nat.add(Nat.add(a, b), c) == Nat.add(a, Nat.add(b, c)) : Nat}:
  match a:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_assoc(p, b, c) : {1n+Nat.add(Nat.add(p, b), c) == 1n+_ : Nat}
      {==}

# ---- Small equational helpers (all unqualified for use in % position) ----

def eq_sym(a: Nat, b: Nat, e: {a == b : Nat}) -> {b == a : Nat}:
  %e : {_ == a : Nat}
  {==}

def nat_add_comm_sym(+a: Nat, +b: Nat) -> {Nat.add(b, a) == Nat.add(a, b) : Nat}:
  eq_sym(Nat.add(a, b), Nat.add(b, a), nat_add_comm(a, b))

def nat_add_assoc_sym(+a: Nat, +b: Nat, +c: Nat) -> {Nat.add(a, Nat.add(b, c)) == Nat.add(Nat.add(a, b), c) : Nat}:
  eq_sym(Nat.add(Nat.add(a, b), c), Nat.add(a, Nat.add(b, c)), nat_add_assoc(a, b, c))

# Rearrangement: (a+b)+(c+d) == (a+c)+(b+d).
def add_rearr(+a: Nat, +b: Nat, +c: Nat, +d: Nat) -> {Nat.add(Nat.add(a, b), Nat.add(c, d)) == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}:
  %nat_add_assoc_sym(a, b, Nat.add(c, d)) : {_ == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  %nat_add_assoc(b, c, d) : {Nat.add(a, _) == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  %nat_add_comm_sym(b, c) : {Nat.add(a, Nat.add(_, d)) == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  %nat_add_assoc_sym(c, b, d) : {Nat.add(a, _) == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  %nat_add_assoc(a, c, Nat.add(b, d)) : {_ == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}
  {==}

# Symmetric rearrangement, for right-to-left rewriting of a LHS occurrence.
def add_rearr_sym(+a: Nat, +b: Nat, +c: Nat, +d: Nat) -> {Nat.add(Nat.add(a, c), Nat.add(b, d)) == Nat.add(Nat.add(a, b), Nat.add(c, d)) : Nat}:
  eq_sym(Nat.add(Nat.add(a, b), Nat.add(c, d)), Nat.add(Nat.add(a, c), Nat.add(b, d)), add_rearr(a, b, c, d))

# zabs_diff is symmetric under simultaneous negation.
def zabs_diff_neg(x: Laws.Z, y: Laws.Z) -> {Laws.zabs_diff(x, y) == Laws.zabs_diff(Laws.zneg(x), Laws.zneg(y)) : Nat}:
  match x:
    case Laws.ZC{+xp, +xn}:
      match y:
        case Laws.ZC{+yp, +yn}:
          nat_add_comm(Nat.sub(Nat.add(xp, yn), Nat.add(xn, yp)), Nat.sub(Nat.add(xn, yp), Nat.add(xp, yn)))


# Helper: from s1==t1 and s2==t2, prove (t1+t2)==(s1+s2).
# _ marks the hypothesis's RHS, replaced by its LHS.
def mid_rewrite2(s1: Nat, t1: Nat, s2: Nat, t2: Nat,
                 e1: {s1 == t1 : Nat}, e2: {s2 == t2 : Nat})
  -> {Nat.add(t1, t2) == Nat.add(s1, s2) : Nat}:
  %e1 : {Nat.add(_, t2) == Nat.add(s1, s2) : Nat}
  %e2 : {Nat.add(s1, _) == Nat.add(s1, s2) : Nat}
  {==}


# Helper: from s1==t1 and s2==t2, prove (s1+s2)==(t1+t2) (forward direction).
# % rewrites right-to-left only, so flip the hypotheses with eq_sym first.
def fwd_rewrite(s1: Nat, t1: Nat, s2: Nat, t2: Nat,
                e1: {s1 == t1 : Nat}, e2: {s2 == t2 : Nat})
  -> {Nat.add(s1, s2) == Nat.add(t1, t2) : Nat}:
  %eq_sym(s1, t1, e1) : {Nat.add(_, s2) == Nat.add(t1, t2) : Nat}
  %eq_sym(s2, t2, e2) : {Nat.add(t1, _) == Nat.add(t1, t2) : Nat}
  {==}

# ---- Law fillers ----

def Laws.zadd_congr(xp1, xn1, yp1, yn1, xp2, xn2, yp2, yn2, e1, e2):
  %add_rearr_sym(xp1, xp2, yn1, yn2) : {_ == Nat.add(Nat.add(yp1, yp2), Nat.add(xn1, xn2)) : Nat}
  %add_rearr_sym(yp1, yp2, xn1, xn2) : {Nat.add(Nat.add(xp1, yn1), Nat.add(xp2, yn2)) == _ : Nat}
  %e1 : {Nat.add(Nat.add(xp1, yn1), Nat.add(xp2, yn2)) == Nat.add(_, Nat.add(yp2, xn2)) : Nat}
  %e2 : {Nat.add(Nat.add(xp1, yn1), Nat.add(xp2, yn2)) == Nat.add(Nat.add(xp1, yn1), _) : Nat}
  {==}

def Laws.zneg_congr(xp, xn, yp, yn, e):
  %nat_add_comm_sym(xn, yp) : {_ == Nat.add(yn, xp) : Nat}
  %nat_add_comm_sym(yn, xp) : {Nat.add(yp, xn) == _ : Nat}
  %e : {_ == Nat.add(xp, yn) : Nat}
  {==}

# Part B filler: k is needed twice in term position (two Laws.M(k) calls),
# so delegate to a helper with copyable (+) params; the law filler just calls it.
def neg_preserves_go(+k: Nat, +n: Nat, p: {Nat.sub(Laws.zabs_diff(Laws.s(Nat.add(Laws.M(k), n)), Laws.s(Laws.M(k))), 1n) == 0n : Nat}) -> {Nat.sub(Laws.zabs_diff(Laws.zneg(Laws.s(Nat.add(Laws.M(k), n))), Laws.zneg(Laws.s(Laws.M(k)))), 1n) == 0n : Nat}:
  %zabs_diff_neg(Laws.s(Nat.add(Laws.M(k), n)), Laws.s(Laws.M(k))) : {Nat.sub(_, 1n) == 0n : Nat}
  p

def Laws.neg_preserves(k, n, p):
  neg_preserves_go(k, n, p)
