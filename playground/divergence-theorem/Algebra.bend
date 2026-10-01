import Base
import ./LAWS.bend as Laws

# GREEN, then REFACTOR (see README.md).
#
# The whole proof is one cancellation: the shared interior face s
# appears in both cubes' divergences, so (s+A)+(s+B) = A+B.
# Case-split on s: False computes away, True needs the lemma that
# double negation cancels under XOR.
#
# Reusable core: xor_not_not and shared_face_cancels are pure Z/2
# algebra, independent of cubes — candidates for a verified boolean
# algebra package (bend-packages#75 wants the automation; #70 the numbers).

# LEMMA (pure algebra): negating both sides of an XOR changes nothing.
# Brute force over 2^2 = 4 cases; each side computes to constructors.
def xor_not_not(+x: Bool, +y: Bool)
  -> {Bool.xor(Bool.not(x), Bool.not(y)) == Bool.xor(x, y) : Bool}:
  match x:
    case True{}:
      match y:
        case True{}:
          {==}
        case False{}:
          {==}
    case False{}:
      match y:
        case True{}:
          {==}
        case False{}:
          {==}

# LEMMA: the shared face cancels. (s+A)+(s+B) = A+B over Z/2.
# Case s = False: xor(False, v) computes to v on both sides.
# Case s = True:  xor(True, v) computes to not(v); apply xor_not_not.
def shared_face_cancels(+s: Bool, +A: Bool, +B: Bool)
  -> {Bool.xor(Bool.xor(s, A), Bool.xor(s, B)) == Bool.xor(A, B) : Bool}:
  match s:
    case False{}:
      {==}
    case True{}:
      xor_not_not(A, B)

