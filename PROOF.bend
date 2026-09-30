import Base
import ./Expr.bend as Expr
import ./LAWS.bend as Laws

# The actual induction, as a regular def. It takes a reusable y (so the
# proof can mention it many times) and returns the proposition as an
# explicit type. A recursive call is the induction hypothesis; %e : P
# rewrites the goal with the equation e (right-hand side occurrences
# marked with _); {==} closes goals whose sides compute to the same term.
def diff_correct_aux(e: Expr.Expr, +y: U32) -> {Expr.evald(e, y, 1) == Expr.eval(Expr.diff(e), y) : U32}:
  match e:
    case Expr.Cst{_}:
      # evald(Cst, y, 1) = 0 = eval(diff(Cst), y): both sides compute to 0.
      {==}
    case Expr.Var{}:
      # evald(Var, y, 1) = 1 = eval(diff(Var), y): both sides compute to 1.
      {==}
    case Expr.Add{+l, +r}:
      # Goal computes to:
      #   evald(l,y,1)+evald(r,y,1) == eval(diff(l),y)+eval(diff(r),y).
      # Rewrite the RHS's eval(diff(l),y) back to evald(l,y,1) via the IH,
      # then the same for r. Both sides become identical; {==} closes it.
      %diff_correct_aux(l, y) : {(Expr.evald(l, y, 1) + Expr.evald(r, y, 1) : U32) == (_ + Expr.eval(Expr.diff(r), y) : U32) : U32}
      %diff_correct_aux(r, y) : {(Expr.evald(l, y, 1) + Expr.evald(r, y, 1) : U32) == (Expr.evald(l, y, 1) + _ : U32) : U32}
      {==}
    case Expr.Mul{+l, +r}:
      # Goal computes to:
      #   evald(l,y,1)*eval(r,y) + eval(l,y)*evald(r,y,1)
      #     == eval(diff(l),y)*eval(r,y) + eval(l,y)*eval(diff(r),y).
      # Same rewriting strategy as Add. diff's Mul case was written to
      # expand in exactly the order evald computes, so the sides line up.
      %diff_correct_aux(l, y) : {((Expr.evald(l, y, 1) * Expr.eval(r, y) : U32) + (Expr.eval(l, y) * Expr.evald(r, y, 1) : U32) : U32) == ((_ * Expr.eval(r, y) : U32) + (Expr.eval(l, y) * Expr.eval(Expr.diff(r), y) : U32) : U32) : U32}
      %diff_correct_aux(r, y) : {((Expr.evald(l, y, 1) * Expr.eval(r, y) : U32) + (Expr.eval(l, y) * Expr.evald(r, y, 1) : U32) : U32) == ((Expr.evald(l, y, 1) * Expr.eval(r, y) : U32) + (Expr.eval(l, y) * _ : U32) : U32) : U32}
      {==}

# Fills `law diff_correct` in LAWS.bend. A law-filling def takes plain
# params (no annotations, no +), so it just delegates to the helper —
# e and x are each used exactly once here.
def Laws.diff_correct(e, x):
  diff_correct_aux(e, x)
