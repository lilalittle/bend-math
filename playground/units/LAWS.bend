import Base

# RED phase only (bend-packages#69): physical dimensions as types.
#
# The idea: a physical dimension is a vector of 7 SI base-dimension
# exponents (m, kg, s, A, K, mol, cd). Bend has no signed integers, so we
# keep numerator and denominator exponent vectors apart -- each is 7 Nats.
# `is Data` makes dimensions copyable, so no affine annotations are needed.
# Multiplying dimensions adds exponents; dividing cross-adds. A `dim_norm`
# (cancel common factors) is specified by the laws; its real implementation
# comes with GREEN.

type Exp7 is Data:
  E7{ m: Nat, kg: Nat, s: Nat, amp: Nat, kel: Nat, mol: Nat, cd: Nat }

type Dim is Data:
  Dim{ num: Exp7, den: Exp7 }

def exp7_add(x: Exp7, y: Exp7) -> Exp7:
  match x:
    case E7{+xm, +xkg, +xs, +xamp, +xkel, +xmol, +xcd}:
      match y:
        case E7{+ym, +ykg, +ys, +yamp, +ykel, +ymol, +ycd}:
          E7{ Nat.add(xm, ym), Nat.add(xkg, ykg), Nat.add(xs, ys),
              Nat.add(xamp, yamp), Nat.add(xkel, ykel),
              Nat.add(xmol, ymol), Nat.add(xcd, ycd) }

def exp7_zero() -> Exp7:
  E7{ 0n, 0n, 0n, 0n, 0n, 0n, 0n }

# Multiplying dimensions: add the exponent vectors.
def dim_mul(x: Dim, y: Dim) -> Dim:
  match x:
    case Dim{+xn, +xd}:
      match y:
        case Dim{+yn, +yd}:
          Dim{ exp7_add(xn, yn), exp7_add(xd, yd) }

# Dividing dimensions: cross-add (x.num + y.den over x.den + y.num).
def dim_div(x: Dim, y: Dim) -> Dim:
  match x:
    case Dim{+xn, +xd}:
      match y:
        case Dim{+yn, +yd}:
          Dim{ exp7_add(xn, yd), exp7_add(xd, yn) }

# RED: normalization is specified by the laws below; implemented in GREEN.
def dim_norm(x: Dim) -> Dim:
  x

def dim_dimensionless() -> Dim:
  Dim{ exp7_zero, exp7_zero }

def dim_meter() -> Dim:
  Dim{ E7{ 1n, 0n, 0n, 0n, 0n, 0n, 0n }, exp7_zero }

def dim_second() -> Dim:
  Dim{ E7{ 0n, 0n, 1n, 0n, 0n, 0n, 0n }, exp7_zero }

def dim_velocity() -> Dim:
  dim_div(dim_meter, dim_second)

law dim_mul_assoc:
  for x: Dim
  for y: Dim
  for z: Dim
  {dim_mul(dim_mul(x, y), z) == dim_mul(x, dim_mul(y, z)) : Dim}

law dim_mul_comm:
  for x: Dim
  for y: Dim
  {dim_mul(x, y) == dim_mul(y, x) : Dim}

law dim_mul_unit:
  for x: Dim
  {dim_mul(dim_dimensionless, x) == x : Dim}

law velocity_times_second_is_meter:
  {dim_norm(dim_mul(dim_velocity, dim_second)) == dim_meter : Dim}
