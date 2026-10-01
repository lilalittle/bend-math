import Base
import ./LAWS.bend as Laws
import ./Algebra.bend as Alg

# GREEN: the shared interior face s appears in both divergences and cancels.
# The filler unfolds div_cube/boundary_flux into (s+A)+(s+B) = A+B and
# delegates to the algebra lemma; each param is used exactly once.
def Laws.divergence_two_cubes(s, a1, a2, a3, a4, a5, b1, b2, b3, b4, b5):
  Alg.shared_face_cancels(s,
    Bool.xor(a1, Bool.xor(a2, Bool.xor(a3, Bool.xor(a4, a5)))),
    Bool.xor(b1, Bool.xor(b2, Bool.xor(b3, Bool.xor(b4, b5)))))
