import Base

# PROBE 6 (#76 kill-order, probe 6): compositional scaling.
#
# Question: take two proven components and compose them. Does proof reuse
# compose, or does each composition need handwritten plumbing?
#
# Composition: dot product distributes over vector addition.
#   dot2(a, vec_add(b, c)) == Nat.add(dot2(a, b), dot2(a, c))
#
# Components (proven independently, reused as black boxes):
#   - dot2, vec_add: definitions (computation).
#   - nat_distr: Nat.mul(x, y+z) == Nat.mul(x,y)+Nat.mul(x,z) (probe-4 pattern,
#     proven here by induction; in a real codebase it would be imported).
#   - add_rearr: (a+b)+(c+d) == (a+c)+(b+d).
#
# The composition proof reuses nat_distr and add_rearr WITHOUT reproving them.
# The "plumbing" is: unfolding the definitions (computation), applying nat_distr
# twice (one per component), and one add_rearr to align the terms. All plumbing
# is explicit % rewrites -- the question is how much is needed.

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

# --- Component: nat_distr (probe-4 pattern, self-contained) ---

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

# distr_step BEFORE nat_distr (no forward references).
def distr_step(+p: Nat, +b: Nat, +c: Nat, ih: {Nat.mul(p, Nat.add(b, c)) == Nat.add(Nat.mul(p, b), Nat.mul(p, c)) : Nat}) -> {Nat.mul(1n+p, Nat.add(b, c)) == Nat.add(Nat.mul(1n+p, b), Nat.mul(1n+p, c)) : Nat}:
  %eq_sym(Nat.mul(p, Nat.add(b, c)), Nat.add(Nat.mul(p, b), Nat.mul(p, c)), ih) : {Nat.add(Nat.add(b, c), _) == Nat.add(Nat.add(b, Nat.mul(p, b)), Nat.add(c, Nat.mul(p, c))) : Nat}
  %eq_sym(Nat.add(Nat.add(b, c), Nat.add(Nat.mul(p, b), Nat.mul(p, c))), Nat.add(Nat.add(b, Nat.mul(p, b)), Nat.add(c, Nat.mul(p, c))), add_rearr(b, c, Nat.mul(p, b), Nat.mul(p, c))) : {_ == Nat.add(Nat.add(b, Nat.mul(p, b)), Nat.add(c, Nat.mul(p, c))) : Nat}
  {==}

def nat_distr(+a: Nat, +b: Nat, +c: Nat) -> {Nat.mul(a, Nat.add(b, c)) == Nat.add(Nat.mul(a, b), Nat.mul(a, c)) : Nat}:
  match a:
    case 0n:
      {==}
    case 1n+p:
      distr_step(p, b, c, nat_distr(p, b, c))

# --- The composition law ---
# dot2(a, b+c) == dot2(a,b) + dot2(a,c), for V2 vectors.
# After unfolding definitions, this is:
#   ax*(bx+cx) + ay*(by+cy) == (ax*bx + ay*by) + (ax*cx + ay*cy).

law dot_add_distr:
  for ax: Nat
  for ay: Nat
  for bx: Nat
  for by: Nat
  for cx: Nat
  for cy: Nat
  {dot2(V2{ ax, ay }, vec_add(V2{ bx, by }, V2{ cx, cy })) == Nat.add(dot2(V2{ ax, ay }, V2{ bx, by }), dot2(V2{ ax, ay }, V2{ cx, cy })) : Nat}
