import Base
import ./LAWS.bend as Laws
import ../Core.bend as C

# Wrappers for % (needs bare defined names).
def w_nn(+a: C.Z) -> {a == C.zmul(C.zmul(a, C.zneg(C.zone())), C.zneg(C.zone())) : C.Z}:
  Equal.sym(C.Z, C.zmul(C.zmul(a, C.zneg(C.zone())), C.zneg(C.zone())), a, C.zmul_zmul_nn(a))

def w_1n(+a: C.Z) -> {C.zneg(a) == C.zmul(C.zmul(a, C.zone()), C.zneg(C.zone())) : C.Z}:
  Equal.sym(C.Z, C.zmul(C.zmul(a, C.zone()), C.zneg(C.zone())), C.zneg(a), C.zmul_zmul_1n(a))

def w_11(+a: C.Z) -> {a == C.zmul(C.zmul(a, C.zone()), C.zone()) : C.Z}:
  Equal.sym(C.Z, C.zmul(C.zmul(a, C.zone()), C.zone()), a, C.zmul_zmul_11(a))

def w_n1(+a: C.Z) -> {C.zneg(a) == C.zmul(C.zmul(a, C.zneg(C.zone())), C.zone()) : C.Z}:
  Equal.sym(C.Z, C.zmul(C.zmul(a, C.zneg(C.zone())), C.zone()), C.zneg(a), C.zmul_zmul_n1(a))

def w_zadd_neg(+a: C.Z) -> {True{} == C.z_is_zero(C.zadd(a, C.zneg(a))) : Bool}:
  Equal.sym(Bool, C.z_is_zero(C.zadd(a, C.zneg(a))), True{}, C.zadd_neg_zero(a))

# Helper: zadd_comm wrapped
def my_zadd_comm(+x: C.Z, +y: C.Z) -> {C.zadd(x, y) == C.zadd(y, x) : C.Z}:
  C.zadd_comm(x, y)

def my_zadd_neg_zero(+a: C.Z) -> {C.z_is_zero(C.zadd(a, C.zneg(a))) == True{} : Bool}:
  C.zadd_neg_zero(a)

# z_is_zero(zadd(zneg(a), a)) == True, via comm then zadd_neg_zero.
def zadd_neg_zero_flip(+a: C.Z) -> {C.z_is_zero(C.zadd(C.zneg(a), a)) == True{} : Bool}:
  %Equal.sym(C.Z, C.zadd(C.zneg(a), a), C.zadd(a, C.zneg(a)), my_zadd_comm(C.zneg(a), a)) : {C.z_is_zero(_) == True{} : Bool}
  my_zadd_neg_zero(a)

def w_zadd_neg_flip(+a: C.Z) -> {True{} == C.z_is_zero(C.zadd(C.zneg(a), a)) : Bool}:
  Equal.sym(Bool, C.z_is_zero(C.zadd(C.zneg(a), a)), True{}, zadd_neg_zero_flip(a))

def face_closed(+a: C.Z) -> {C.chain_is_zero(C.boundary(Laws.t_tri(), C.chain_scale(a, C.lookup(Laws.t_tri(), 6n)))) == True{} : Bool}:
  %w_nn(a) : {Bool.and(C.z_is_zero(C.zadd(_, C.zmul(C.zmul(a, C.zone()), C.zneg(C.zone())))), Bool.and(C.z_is_zero(C.zadd(C.zmul(C.zmul(a, C.zone()), C.zneg(C.zone())), C.zmul(C.zmul(a, C.zone()), C.zone()))), Bool.and(C.z_is_zero(C.zadd(C.zmul(C.zmul(a, C.zone()), C.zone()), C.zmul(C.zmul(a, C.zneg(C.zone())), C.zone()))), True{}))) == True{} : Bool}
  %w_1n(a) : {Bool.and(C.z_is_zero(C.zadd(a, _)), Bool.and(C.z_is_zero(C.zadd(C.zmul(C.zmul(a, C.zone()), C.zneg(C.zone())), C.zmul(C.zmul(a, C.zone()), C.zone()))), Bool.and(C.z_is_zero(C.zadd(C.zmul(C.zmul(a, C.zone()), C.zone()), C.zmul(C.zmul(a, C.zneg(C.zone())), C.zone()))), True{}))) == True{} : Bool}
  %w_1n(a) : {Bool.and(C.z_is_zero(C.zadd(a, C.zneg(a))), Bool.and(C.z_is_zero(C.zadd(_, C.zmul(C.zmul(a, C.zone()), C.zone()))), Bool.and(C.z_is_zero(C.zadd(C.zmul(C.zmul(a, C.zone()), C.zone()), C.zmul(C.zmul(a, C.zneg(C.zone())), C.zone()))), True{}))) == True{} : Bool}
  %w_11(a) : {Bool.and(C.z_is_zero(C.zadd(a, C.zneg(a))), Bool.and(C.z_is_zero(C.zadd(C.zneg(a), _)), Bool.and(C.z_is_zero(C.zadd(C.zmul(C.zmul(a, C.zone()), C.zone()), C.zmul(C.zmul(a, C.zneg(C.zone())), C.zone()))), True{}))) == True{} : Bool}
  %w_11(a) : {Bool.and(C.z_is_zero(C.zadd(a, C.zneg(a))), Bool.and(C.z_is_zero(C.zadd(C.zneg(a), a)), Bool.and(C.z_is_zero(C.zadd(_, C.zmul(C.zmul(a, C.zneg(C.zone())), C.zone()))), True{}))) == True{} : Bool}
  %w_n1(a) : {Bool.and(C.z_is_zero(C.zadd(a, C.zneg(a))), Bool.and(C.z_is_zero(C.zadd(C.zneg(a), a)), Bool.and(C.z_is_zero(C.zadd(a, _)), True{}))) == True{} : Bool}
  %w_zadd_neg(a) : {Bool.and(_, Bool.and(C.z_is_zero(C.zadd(C.zneg(a), a)), Bool.and(C.z_is_zero(C.zadd(a, C.zneg(a))), True{}))) == True{} : Bool}
  %w_zadd_neg_flip(a) : {Bool.and(True{}, Bool.and(_, Bool.and(C.z_is_zero(C.zadd(a, C.zneg(a))), True{}))) == True{} : Bool}
  %w_zadd_neg(a) : {Bool.and(True{}, Bool.and(True{}, Bool.and(_, True{}))) == True{} : Bool}
  {==}

# For cells >= 7, lookup returns [] (provable by computation on 7+k).
def cell_closed_big(+k: Nat, +a: C.Z) -> {C.chain_is_zero(C.boundary(Laws.t_tri(), C.chain_scale(a, C.lookup(Laws.t_tri(), Nat.add(7n, k))))) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+j: {==}

def cell_closed_go(+cell: Nat, +a: C.Z) -> {C.chain_is_zero(C.boundary(Laws.t_tri(), C.chain_scale(a, C.lookup(Laws.t_tri(), cell)))) == True{} : Bool}:
  match cell:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n: {==}
    case 5n: {==}
    case 6n: face_closed(a)
    case 7n+k: cell_closed_big(k, a)

def Laws.cell_closed(cell, a):
  cell_closed_go(cell, a)

def Laws.b2(c):
  ?TODO
