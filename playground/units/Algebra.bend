import Base
import ./LAWS.bend as Laws

# GREEN, then REFACTOR (see README.md).
#
# Two parts, layered:
#   Part 1 — verified Nat arithmetic (nat_add_zero_r, nat_add_succ_r,
#     nat_add_comm, nat_add_assoc). Base doesn't verify these; they are
#     proved here by induction and are reusable anywhere Nats are added.
#     This is the seed of a verified-Nat package (bend-packages#70).
#   Part 2 — dimension algebra: the Nat lemmas lifted componentwise to
#     Exp7 (7 rewrite steps each; the blocks are machine-generated
#     boilerplate — the proof is in the Nat lemmas) and assembled into
#     the Dim monoid laws.
#
# Rewrite discipline throughout: each lemma is stated
# {replacement == pattern}, so %e : P can eliminate `pattern`
# occurrences from a goal.

# ============================================================
# Part 1: verified Nat arithmetic
# ============================================================

# LEMMA: n replaces Nat.add(n, 0n). Induction on n.
def nat_add_zero_r(+n: Nat) -> {n == Nat.add(n, 0n) : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_zero_r(p) : {1n+p == 1n+_ : Nat}
      {==}

# LEMMA: 1n+Nat.add(n,m) replaces Nat.add(n, 1n+m). Induction on n.
def nat_add_succ_r(+n: Nat, +m: Nat) -> {1n+Nat.add(n, m) == Nat.add(n, 1n+m) : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_succ_r(p, m) : {1n+(1n+Nat.add(p, m)) == 1n+_ : Nat}
      {==}

# LEMMA: Nat.add is commutative. Induction on a.
def nat_add_comm(+a: Nat, +b: Nat) -> {Nat.add(a, b) == Nat.add(b, a) : Nat}:
  match a:
    case 0n:
      %nat_add_zero_r(b) : {b == _ : Nat}
      {==}
    case 1n+p:
      %nat_add_succ_r(b, p) : {1n+Nat.add(p, b) == _ : Nat}
      %nat_add_comm(p, b) : {1n+Nat.add(p, b) == 1n+_ : Nat}
      {==}

# LEMMA: Nat.add is associative. Induction on a.
def nat_add_assoc(+a: Nat, +b: Nat, +c: Nat) -> {Nat.add(Nat.add(a, b), c) == Nat.add(a, Nat.add(b, c)) : Nat}:
  match a:
    case 0n:
      {==}
    case 1n+p:
      %nat_add_assoc(p, b, c) : {1n+Nat.add(Nat.add(p, b), c) == 1n+_ : Nat}
      {==}

# ============================================================
# Part 2: dimension algebra (Exp7, then Dim)
# ============================================================

# LEMMA: exp7_add is commutative. Destructure both sides; rewrite
# each of the 7 components backwards with nat_add_comm.
def exp7_add_comm(+x: Laws.Exp7, +y: Laws.Exp7)
  -> {Laws.exp7_add(x, y) == Laws.exp7_add(y, x) : Laws.Exp7}:
  match x:
    case Laws.E7{+xm, +xkg, +xs, +xamp, +xkel, +xmol, +xcd}:
      match y:
        case Laws.E7{+ym, +ykg, +ys, +yamp, +ykel, +ymol, +ycd}:
          %nat_add_comm(xm, ym) : {Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), Nat.add(xkel, ykel), Nat.add(xmol, ymol), Nat.add(xcd, ycd)} == Laws.E7{_, Nat.add(ykg, xkg), Nat.add(ys, xs), Nat.add(yamp, xamp), Nat.add(ykel, xkel), Nat.add(ymol, xmol), Nat.add(ycd, xcd)} : Laws.Exp7}
          %nat_add_comm(xkg, ykg) : {Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), Nat.add(xkel, ykel), Nat.add(xmol, ymol), Nat.add(xcd, ycd)} == Laws.E7{Nat.add(xm, ym), _, Nat.add(ys, xs), Nat.add(yamp, xamp), Nat.add(ykel, xkel), Nat.add(ymol, xmol), Nat.add(ycd, xcd)} : Laws.Exp7}
          %nat_add_comm(xs, ys) : {Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), Nat.add(xkel, ykel), Nat.add(xmol, ymol), Nat.add(xcd, ycd)} == Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), _, Nat.add(yamp, xamp), Nat.add(ykel, xkel), Nat.add(ymol, xmol), Nat.add(ycd, xcd)} : Laws.Exp7}
          %nat_add_comm(xamp, yamp) : {Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), Nat.add(xkel, ykel), Nat.add(xmol, ymol), Nat.add(xcd, ycd)} == Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), _, Nat.add(ykel, xkel), Nat.add(ymol, xmol), Nat.add(ycd, xcd)} : Laws.Exp7}
          %nat_add_comm(xkel, ykel) : {Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), Nat.add(xkel, ykel), Nat.add(xmol, ymol), Nat.add(xcd, ycd)} == Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), _, Nat.add(ymol, xmol), Nat.add(ycd, xcd)} : Laws.Exp7}
          %nat_add_comm(xmol, ymol) : {Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), Nat.add(xkel, ykel), Nat.add(xmol, ymol), Nat.add(xcd, ycd)} == Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), Nat.add(xkel, ykel), _, Nat.add(ycd, xcd)} : Laws.Exp7}
          %nat_add_comm(xcd, ycd) : {Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), Nat.add(xkel, ykel), Nat.add(xmol, ymol), Nat.add(xcd, ycd)} == Laws.E7{Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys), Nat.add(xamp, yamp), Nat.add(xkel, ykel), Nat.add(xmol, ymol), _} : Laws.Exp7}
          {==}

# LEMMA: exp7_add is associative. Same shape, nat_add_assoc.
def exp7_add_assoc(+x: Laws.Exp7, +y: Laws.Exp7, +z: Laws.Exp7)
  -> {Laws.exp7_add(Laws.exp7_add(x, y), z) == Laws.exp7_add(x, Laws.exp7_add(y, z)) : Laws.Exp7}:
  match x:
    case Laws.E7{+xm, +xkg, +xs, +xamp, +xkel, +xmol, +xcd}:
      match y:
        case Laws.E7{+ym, +ykg, +ys, +yamp, +ykel, +ymol, +ycd}:
          match z:
            case Laws.E7{+zm, +zkg, +zs, +zamp, +zkel, +zmol, +zcd}:
              %nat_add_assoc(xm, ym, zm) : {Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), Nat.add(Nat.add(xkel, ykel), zkel), Nat.add(Nat.add(xmol, ymol), zmol), Nat.add(Nat.add(xcd, ycd), zcd)} == Laws.E7{_, Nat.add(xkg, Nat.add(ykg, zkg)), Nat.add(xs, Nat.add(ys, zs)), Nat.add(xamp, Nat.add(yamp, zamp)), Nat.add(xkel, Nat.add(ykel, zkel)), Nat.add(xmol, Nat.add(ymol, zmol)), Nat.add(xcd, Nat.add(ycd, zcd))} : Laws.Exp7}
              %nat_add_assoc(xkg, ykg, zkg) : {Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), Nat.add(Nat.add(xkel, ykel), zkel), Nat.add(Nat.add(xmol, ymol), zmol), Nat.add(Nat.add(xcd, ycd), zcd)} == Laws.E7{Nat.add(Nat.add(xm, ym), zm), _, Nat.add(xs, Nat.add(ys, zs)), Nat.add(xamp, Nat.add(yamp, zamp)), Nat.add(xkel, Nat.add(ykel, zkel)), Nat.add(xmol, Nat.add(ymol, zmol)), Nat.add(xcd, Nat.add(ycd, zcd))} : Laws.Exp7}
              %nat_add_assoc(xs, ys, zs) : {Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), Nat.add(Nat.add(xkel, ykel), zkel), Nat.add(Nat.add(xmol, ymol), zmol), Nat.add(Nat.add(xcd, ycd), zcd)} == Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), _, Nat.add(xamp, Nat.add(yamp, zamp)), Nat.add(xkel, Nat.add(ykel, zkel)), Nat.add(xmol, Nat.add(ymol, zmol)), Nat.add(xcd, Nat.add(ycd, zcd))} : Laws.Exp7}
              %nat_add_assoc(xamp, yamp, zamp) : {Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), Nat.add(Nat.add(xkel, ykel), zkel), Nat.add(Nat.add(xmol, ymol), zmol), Nat.add(Nat.add(xcd, ycd), zcd)} == Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), _, Nat.add(xkel, Nat.add(ykel, zkel)), Nat.add(xmol, Nat.add(ymol, zmol)), Nat.add(xcd, Nat.add(ycd, zcd))} : Laws.Exp7}
              %nat_add_assoc(xkel, ykel, zkel) : {Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), Nat.add(Nat.add(xkel, ykel), zkel), Nat.add(Nat.add(xmol, ymol), zmol), Nat.add(Nat.add(xcd, ycd), zcd)} == Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), _, Nat.add(xmol, Nat.add(ymol, zmol)), Nat.add(xcd, Nat.add(ycd, zcd))} : Laws.Exp7}
              %nat_add_assoc(xmol, ymol, zmol) : {Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), Nat.add(Nat.add(xkel, ykel), zkel), Nat.add(Nat.add(xmol, ymol), zmol), Nat.add(Nat.add(xcd, ycd), zcd)} == Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), Nat.add(Nat.add(xkel, ykel), zkel), _, Nat.add(xcd, Nat.add(ycd, zcd))} : Laws.Exp7}
              %nat_add_assoc(xcd, ycd, zcd) : {Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), Nat.add(Nat.add(xkel, ykel), zkel), Nat.add(Nat.add(xmol, ymol), zmol), Nat.add(Nat.add(xcd, ycd), zcd)} == Laws.E7{Nat.add(Nat.add(xm, ym), zm), Nat.add(Nat.add(xkg, ykg), zkg), Nat.add(Nat.add(xs, ys), zs), Nat.add(Nat.add(xamp, yamp), zamp), Nat.add(Nat.add(xkel, ykel), zkel), Nat.add(Nat.add(xmol, ymol), zmol), _} : Laws.Exp7}
              {==}

# The three dimension laws, assembled from the Exp7 lemmas.
def dim_mul_assoc(+x: Laws.Dim, +y: Laws.Dim, +z: Laws.Dim)
  -> {Laws.dim_mul(Laws.dim_mul(x, y), z) == Laws.dim_mul(x, Laws.dim_mul(y, z)) : Laws.Dim}:
  match x:
    case Laws.Dim{+xn, +xd}:
      match y:
        case Laws.Dim{+yn, +yd}:
          match z:
            case Laws.Dim{+zn, +zd}:
              %exp7_add_assoc(xn, yn, zn) : {Laws.Dim{Laws.exp7_add(Laws.exp7_add(xn, yn), zn), Laws.exp7_add(Laws.exp7_add(xd, yd), zd)} == Laws.Dim{_, Laws.exp7_add(xd, Laws.exp7_add(yd, zd))} : Laws.Dim}
              %exp7_add_assoc(xd, yd, zd) : {Laws.Dim{Laws.exp7_add(Laws.exp7_add(xn, yn), zn), Laws.exp7_add(Laws.exp7_add(xd, yd), zd)} == Laws.Dim{Laws.exp7_add(Laws.exp7_add(xn, yn), zn), _} : Laws.Dim}
              {==}

def dim_mul_comm(+x: Laws.Dim, +y: Laws.Dim)
  -> {Laws.dim_mul(x, y) == Laws.dim_mul(y, x) : Laws.Dim}:
  match x:
    case Laws.Dim{+xn, +xd}:
      match y:
        case Laws.Dim{+yn, +yd}:
          %exp7_add_comm(xn, yn) : {Laws.Dim{Laws.exp7_add(xn, yn), Laws.exp7_add(xd, yd)} == Laws.Dim{_, Laws.exp7_add(yd, xd)} : Laws.Dim}
          %exp7_add_comm(xd, yd) : {Laws.Dim{Laws.exp7_add(xn, yn), Laws.exp7_add(xd, yd)} == Laws.Dim{Laws.exp7_add(xn, yn), _} : Laws.Dim}
          {==}

# dim_mul by the dimensionless dimension: Nat.add(0n, n) computes to n,
# so after destructuring both sides are identical.
def dim_mul_unit(+x: Laws.Dim) -> {Laws.dim_mul(Laws.dim_dimensionless, x) == x : Laws.Dim}:
  match x:
    case Laws.Dim{+xn, +xd}:
      match xn:
        case Laws.E7{+nm, +nkg, +ns, +namp, +nkel, +nmol, +ncd}:
          match xd:
            case Laws.E7{+dm, +dkg, +ds, +damp, +dkel, +dmol, +dcd}:
              {==}

