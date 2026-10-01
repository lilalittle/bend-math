import Base
import ./LAWS.bend as Laws
import ./Algebra.bend as Alg

# GREEN: all four dimension laws proved. The monoid laws delegate to the
# Algebra.bend helpers (each filler uses its params exactly once); the
# headline law (m/s)*s = m holds by computation, so {==} closes it.

def Laws.dim_mul_assoc(x, y, z):
  Alg.dim_mul_assoc(x, y, z)

def Laws.dim_mul_comm(x, y):
  Alg.dim_mul_comm(x, y)

def Laws.dim_mul_unit(x):
  Alg.dim_mul_unit(x)

def Laws.velocity_times_second_is_meter():
  {==}
