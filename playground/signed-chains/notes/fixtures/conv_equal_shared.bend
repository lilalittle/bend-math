import Base

# inject(n, bit): bit sits at depth n inside nested Nat.add(_, 0n).
def inject(n: Nat, bit: Nat) -> Nat:
  match n:
    case 0n:
      bit
    case 1n+m:
      Nat.add(inject(m, bit), 0n)

law equal_shared:
  {inject(30n, 0n) == inject(30n, 0n) : Nat}

def equal_shared():
  {==}
