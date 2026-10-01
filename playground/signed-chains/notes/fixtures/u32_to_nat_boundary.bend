import Base

# U32.to_nat boundary values: 0, 1, 2^31-1, 2^31, 2^32-2, 2^32-1
# (decimal; Bend has no hex literals). The 2.0.33 native widening fix
# touched this path; the executable must agree on both toolchains
# (runtime semantics, separate from checking).
def main() -> IO(Unit):
  IO.print("to_nat(0)      = " ++ Nat.show(U32.to_nat(0)) ++ "\n"
    ++ "to_nat(1)      = " ++ Nat.show(U32.to_nat(1)) ++ "\n"
    ++ "to_nat(2^31-1) = " ++ Nat.show(U32.to_nat(2147483647)) ++ "\n"
    ++ "to_nat(2^31)   = " ++ Nat.show(U32.to_nat(2147483648)) ++ "\n"
    ++ "to_nat(2^32-2) = " ++ Nat.show(U32.to_nat(4294967294)) ++ "\n"
    ++ "to_nat(2^32-1) = " ++ Nat.show(U32.to_nat(4294967295)))
