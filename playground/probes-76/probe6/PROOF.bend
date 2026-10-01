import Base
import ./LAWS.bend as Laws

# Unqualified wrappers for % rewrites (% needs a bare defined name).
def sym(a: Nat, b: Nat, e: {a == b : Nat}) -> {b == a : Nat}:
  Laws.eq_sym(a, b, e)

def distr(+a: Nat, +b: Nat, +c: Nat) -> {Nat.mul(a, Nat.add(b, c)) == Nat.add(Nat.mul(a, b), Nat.mul(a, c)) : Nat}:
  Laws.nat_distr(a, b, c)

def rearr(+a: Nat, +b: Nat, +c: Nat, +d: Nat) -> {Nat.add(Nat.add(a, b), Nat.add(c, d)) == Nat.add(Nat.add(a, c), Nat.add(b, d)) : Nat}:
  Laws.add_rearr(a, b, c, d)

# The composition. Components nat_distr and add_rearr are reused as black boxes
# (no reproving). The plumbing: unfold (computation), two nat_distr applications
# (one per vector component), one add_rearr to align. All explicit.
def dot_add_distr_go(+ax: Nat, +ay: Nat, +bx: Nat, +by: Nat, +cx: Nat, +cy: Nat) -> {Laws.dot2(Laws.V2{ ax, ay }, Laws.vec_add(Laws.V2{ bx, by }, Laws.V2{ cx, cy })) == Nat.add(Laws.dot2(Laws.V2{ ax, ay }, Laws.V2{ bx, by }), Laws.dot2(Laws.V2{ ax, ay }, Laws.V2{ cx, cy })) : Nat}:
  %sym(Nat.mul(ax, Nat.add(bx, cx)), Nat.add(Nat.mul(ax, bx), Nat.mul(ax, cx)), distr(ax, bx, cx)) : {Nat.add(_, Nat.mul(ay, Nat.add(by, cy))) == Nat.add(Nat.add(Nat.mul(ax, bx), Nat.mul(ay, by)), Nat.add(Nat.mul(ax, cx), Nat.mul(ay, cy))) : Nat}
  %sym(Nat.mul(ay, Nat.add(by, cy)), Nat.add(Nat.mul(ay, by), Nat.mul(ay, cy)), distr(ay, by, cy)) : {Nat.add(Nat.add(Nat.mul(ax, bx), Nat.mul(ax, cx)), _) == Nat.add(Nat.add(Nat.mul(ax, bx), Nat.mul(ay, by)), Nat.add(Nat.mul(ax, cx), Nat.mul(ay, cy))) : Nat}
  %sym(Nat.add(Nat.add(Nat.mul(ax, bx), Nat.mul(ax, cx)), Nat.add(Nat.mul(ay, by), Nat.mul(ay, cy))), Nat.add(Nat.add(Nat.mul(ax, bx), Nat.mul(ay, by)), Nat.add(Nat.mul(ax, cx), Nat.mul(ay, cy))), rearr(Nat.mul(ax, bx), Nat.mul(ax, cx), Nat.mul(ay, by), Nat.mul(ay, cy))) : {_ == Nat.add(Nat.add(Nat.mul(ax, bx), Nat.mul(ay, by)), Nat.add(Nat.mul(ax, cx), Nat.mul(ay, cy))) : Nat}
  {==}

def Laws.dot_add_distr(ax, ay, bx, by, cx, cy):
  dot_add_distr_go(ax, ay, bx, by, cx, cy)
