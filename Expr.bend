import Base

# Symbolic expressions in one variable ("x"), over U32.
# This is the executable math: expressions are data, and the
# operations below *run* — they are not just notation.
type Expr is Data:
  Cst{v: U32}
  Var{}
  Add{l: Expr, r: Expr}
  Mul{l: Expr, r: Expr}

# eval(e, x): the value of e with Var bound to x.
def eval(e: Expr, +x: U32) -> U32:
  match e:
    case Cst{v}:
      v
    case Var{}:
      x
    case Add{l, r}:
      (eval(l, x) + eval(r, x) : U32)
    case Mul{l, r}:
      (eval(l, x) * eval(r, x) : U32)

# diff(e): the symbolic derivative of e with respect to Var,
# using the sum and product rules.
def diff(e: Expr) -> Expr:
  match e:
    case Cst{_}:
      Cst{0}
    case Var{}:
      Cst{1}
    case Add{l, r}:
      Add{diff(l), diff(r)}
    case Mul{+l, +r}:
      Add{Mul{diff(l), r}, Mul{l, diff(r)}}

# evald(e, x, dx): forward-mode automatic differentiation.
# Evaluates e at x while propagating the tangent dx alongside
# the primal value. With dx = 1 this computes "the derivative",
# numerically, without ever building a symbolic expression.
def evald(e: Expr, +x: U32, +dx: U32) -> U32:
  match e:
    case Cst{_}:
      0
    case Var{}:
      dx
    case Add{l, r}:
      (evald(l, x, dx) + evald(r, x, dx) : U32)
    case Mul{+l, +r}:
      ((evald(l, x, dx) * eval(r, x) : U32) + (eval(l, x) * evald(r, x, dx) : U32) : U32)
