import Base

# tower(n): as an unfolded tree this has 2^n nodes; as a shared graph it
# is linear. 2.0.33+: "two copies of one term are equal before either
# unfolds" -- the speedup claim under test.
def tower(n: Nat) -> Nat:
  match n:
    case 0n:
      1n
    case 1n+m:
      +t = tower(m)
      Nat.add(t, t)

law equal_copies:
  {tower(20n) == tower(20n) : Nat}

def equal_copies():
  {==}
