import Base

def inject(n: Nat, bit: Nat) -> Nat:
  match n:
    case 0n:
      bit
    case 1n+m:
      Nat.add(inject(m, bit), 0n)

# The two sides are identical except for ONE leaf at depth 30.
# The checker MUST reject this: acceptance would be a soundness bug
# in the shared-graph conversion.
law unequal_deep:
  {inject(30n, 0n) == inject(30n, 1n) : Nat}

def unequal_deep():
  {==}
