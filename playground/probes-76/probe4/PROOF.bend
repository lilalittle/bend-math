import Base
import ./LAWS.bend as Laws

# Each instantiation is a one-line application of the single proven identity.
# No proof code is duplicated; nat_distr is the only proof.

def Laws.distr_inst1():
  Laws.nat_distr(2n, 3n, 4n)

def Laws.distr_inst2():
  Laws.nat_distr(5n, 6n, 7n)

def Laws.distr_inst3(x):
  Laws.nat_distr(x, 1n, 1n)
