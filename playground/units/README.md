# Physical dimensions as types (rung 3, RED phase only)

**Status: 🔴 RED.** The laws are stated; nothing is proved yet. This folder
exists so the next session can pick up at GREEN.

## The idea

A physical dimension is a vector of 7 SI base-dimension exponents
(m, kg, s, A, K, mol, cd). Bend has no signed integers, so numerator and
denominator exponent vectors are kept apart — each is 7 Nats. `is Data` makes
dimensions copyable, so no affine annotations clutter the arithmetic.

- `dim_mul` adds exponent vectors (needs only `Nat.add`)
- `dim_div` cross-adds
- `dim_norm` cancels common factors — **specified by the laws, implemented in
  GREEN** (needs `Nat.min`/`Nat.sub` per component)

## The laws

- `dim_mul_assoc`, `dim_mul_comm`, `dim_mul_unit` — dimensions form a
  commutative monoid (the arithmetic everything else rests on)
- `velocity_times_second_is_meter` — the headline: (m/s)·s normalizes to m

## Out of scope for this rung

Making "adding meters to seconds a type error" needs a *quantity* level
(values tagged with dimensions) on top of this dimension arithmetic — that's
the next step after these laws go green.

## Files

- `LAWS.bend` — the spec: `Exp7`, `Dim`, arithmetic, the four laws
- `PROOF.bend` — `?TODO` fillers (RED state)
- `RED.txt` — the checker transcript
