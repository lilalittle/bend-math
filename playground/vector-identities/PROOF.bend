import Base
import ./LAWS.bend as Laws
import ./Algebra.bend as Alg

# REFACTOR: the pure-algebra lemmas now live in Algebra.bend -- the
# seed of a publishable package. The fillers below just delegate;
# the checker still verifies the connection by unfolding definitions.
# The laws follow by unfolding the definitions: each law's statement
# *computes to* its lemma's left-hand side. If a refactor broke the
# connection, the checker would reject these lines.
def Laws.curl_grad_zero(a, b, c):
  Alg.grad_curl_cancel(a, b, c)

def Laws.div_curl_zero(e01, e02, e03, e12, e13, e23):
  Alg.curl_div_cancel(e01, e02, e03, e12, e13, e23)

def Laws.div_grad_is_laplacian(a, b, c):
  Alg.div_grad_laplacian(a, b, c)
