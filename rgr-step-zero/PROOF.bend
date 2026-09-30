import Base
import ./LAWS.bend as Laws

# REFACTOR: the 8-case analysis never used the triangle — it only used
# the algebra of XOR. Extract it as a standalone, reusable lemma:
# the XOR of the three pairwise differences always cancels.
# (This lemma is pure algebra; it will be reused by the vector-calculus
# identities next — this is where a publishable package is born.)
def xor_cancel3(+x: Bool, +y: Bool, +z: Bool)
  -> {Bool.xor(Bool.xor(x, y), Bool.xor(Bool.xor(y, z), Bool.xor(x, z))) == False{} : Bool}:
  match x:
    case True{}:
      match y:
        case True{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
        case False{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
    case False{}:
      match y:
        case True{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
        case False{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}

# d2_zero now follows by unfolding the definitions: d2(a,b,c) *computes*
# to exactly the lemma's left-hand side. If the restructuring broke the
# connection, the checker would reject this line.
def Laws.d2_zero(a, b, c):
  xor_cancel3(a, b, c)
