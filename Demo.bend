import Base
import ./Expr.bend as Expr

# Executable demo: e = x^2 + 3x.
# At x = 5: value is 25 + 15 = 40, derivative 2x + 3 = 13.
# evald computes the derivative numerically (forward-mode AD);
# eval(diff(e)) computes it symbolically. The law in LAWS.bend
# is the machine-checked proof that they always agree.
def main() -> IO(Unit):
  do IO<Unit>:
    +e : Expr.Expr = Expr.Add{Expr.Mul{Expr.Var{}, Expr.Var{}}, Expr.Mul{Expr.Cst{3}, Expr.Var{}}}
    IO.print("e = x^2 + 3x, at x = 5")
    IO.print("eval(e, 5)        = " ++ U32.show(Expr.eval(e, 5)))
    IO.print("evald(e, 5, 1)    = " ++ U32.show(Expr.evald(e, 5, 1)))
    IO.print("eval(diff(e), 5)  = " ++ U32.show(Expr.eval(Expr.diff(e), 5)))
