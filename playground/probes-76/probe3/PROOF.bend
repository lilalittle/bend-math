import Base
import ./LAWS.bend as Laws

# nat_add_comm is proven here (not imported from Base -- Base doesn't have it).
def Laws.nat_comm_provable(a, b):
  Laws.nat_add_comm(a, b)

# U32.add_comm is consumed from Base (verified there via Word.add_comm).
# (import Base brings it into scope unqualified.)
def Laws.u32_comm_available(a, b):
  U32.add_comm(a, b)

# The transfer: the proof term IS the evidence that the equation holds.
# (For small values this computes at runtime; for huge values the runtime
# cannot represent the inputs -- the proof is about the math, not the stack.)
def Laws.small_nat_comm_transfer(a, b, ha, hb):
  Laws.nat_add_comm(a, b)
