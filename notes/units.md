# Physical dimensions and units

**Statement:** a dimension is a vector of SI base-dimension exponents; multiplying
quantities adds dimensions, and normalization cancels common factors — so
(m/s)·s provably equals m.

**Why it matters:** dimensional analysis is the cheapest error-check in physics:
if the dimensions don't match, the equation is wrong. Making dimensions *types*
turns that check into a machine-verified law instead of a back-of-the-envelope
habit. It's also the first rung where the formalization needed arithmetic Bend
doesn't ship verified — and had to earn it.

**In the playground:** [`playground/units/`](../playground/units/) represents a
dimension as two 7-Nat vectors (m, kg, s, A, K, mol, cd) — numerator and denominator
exponents kept apart, since Bend has no signed integers. `is Data` keeps the
arithmetic affine-free. `dim_mul`/`dim_div` add exponent vectors; `dim_norm`
cancels per component via `(n, d) -> (n - min(n,d), d - min(n,d))`.

Four laws, all green:
- `dim_mul_assoc`, `dim_mul_comm` — dimensions form a commutative monoid.
- `dim_mul_unit` — the dimensionless dimension is the identity.
- `velocity_times_second_is_meter` — (m/s)·s = m, proved *by computation*:
  `dim_norm` cancels the seconds and both sides reduce to the same term, so
  `{==}` closes it with no rewrite steps at all.

**The proof's real content** is one layer down: Base doesn't verify `Nat.add`
commutativity or associativity, so both were proved by induction
(`nat_add_zero_r`, `nat_add_succ_r`, `nat_add_comm`, `nat_add_assoc`), lifted
componentwise to the 7-vectors, and assembled into the `Dim` laws. Those Nat
lemmas are reusable anywhere — they're the seed of
[verified integers and rationals](https://github.com/lilalittle/bend-packages/issues/70)
(rung 5).

**Checker lesson:** `%e : P` validates by checking `P` with `_` filled by the
*RHS* of `e` against the goal's *current* state — after previous rewrites, not
the original goal. Every `_` must sit exactly where the equation's right-hand
side occurs right now.

**What's next:** this rung proves dimension *arithmetic*. Making "adding meters
to seconds" a type error needs a *quantity* level — values tagged with their
dimension — on top of it. That, plus real unit conversions (meters ↔ feet need
rationals), waits on rung 5.

## See also

- [Learning path](learning-path.md) — rung 3
- [The RGR loop](rgr-loop.md) — red → green → refactor, the working method
- [Why Bend is cool](why-bend-is-cool.md) — affine types and interaction nets
- [bend-packages#69](https://github.com/lilalittle/bend-packages/issues/69) — the issue this rung closes
