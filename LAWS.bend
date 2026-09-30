import Base
import ./Expr.bend as Expr

# LAW: forward-mode AD agrees with symbolic differentiation.
#
# For every expression e and every x: evaluating the tangent of e
# at (x, dx=1) gives the same number as evaluating the *symbolic*
# derivative of e at x.
#
# Two completely different implementations of "the derivative" —
# one numeric (evald), one symbolic (diff + eval) — must agree.
# Refactor either one however you like: `bend PROOF.bend` fails
# until this law holds again.
law diff_correct:
  for e: Expr.Expr
  for x: U32
  {Expr.evald(e, x, 1) == Expr.eval(Expr.diff(e), x) : U32}
