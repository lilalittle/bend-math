# Physical dimensions as types (rung 3, 🟢 GREEN → 🔵 REFACTOR)

**Status: 🟢 GREEN, 🔵 REFACTORED.** All four laws proved; `bend PROOF.bend`
prints `All terms check.`

## The idea

A physical dimension is a vector of 7 SI base-dimension exponents
(m, kg, s, A, K, mol, cd). Bend has no signed integers, so numerator and
denominator exponent vectors are kept apart — each is 7 Nats. `is Data` makes
dimensions copyable, so no affine annotations clutter the arithmetic.

- `dim_mul` adds exponent vectors (needs only `Nat.add`)
- `dim_div` cross-adds
- `dim_norm` cancels common factors per component:
  `(n, d) -> (n - min(n,d), d - min(n,d))` via `Nat.sub`/`Nat.min`

## The RGR story

**🔴 RED:** 4 laws stated with `?TODO`; gate failed honestly
(`Error: 4 TODOs found` — see RED.txt).

**🟢 GREEN:** The three monoid laws needed `Nat.add` commutativity and
associativity, which Base doesn't verify — so they were proved by induction
(`nat_add_zero_r`, `nat_add_succ_r`, `nat_add_comm`, `nat_add_assoc`), lifted
componentwise to `Exp7` (7 rewrite steps each), and assembled into the `Dim`
laws. The headline law `(m/s)·s = m` holds *by computation*: `dim_norm`
cancels the seconds and both sides reduce to the same term, so `{==}` closes
it. See GREEN.txt.

**🔵 REFACTOR:** `Algebra.bend` is organized in two layers — Part 1 is
reusable verified Nat arithmetic (the seed of a verified-Nat package for
bend-packages#70); Part 2 is the dimension-specific lifting. The 7-step
Exp7 rewrite blocks are machine-generated boilerplate; the proof content
lives in the Nat induction lemmas. Gate still green — see REFACTOR.txt.

## Bend lessons (new)

- `%e : P` validates by checking `P` with `_` filled by the **RHS** of `e`
  against the current goal — every `_` must sit exactly where the equation's
  right-hand side occurs *in the goal's current state* (after previous
  rewrites in the sequence, not the original state).
- To debug a rewrite, state the goal with `?name` and read the checker's
  `expected` (actual goal) vs `observed` (`P` with `_` := RHS of evidence).

## Out of scope for this rung

Making "adding meters to seconds a type error" needs a *quantity* level
(values tagged with dimensions) on top of this dimension arithmetic — that's
the next step after these laws go green.

## Files

- `LAWS.bend` — the spec: `Exp7`, `Dim`, arithmetic, `dim_norm`, the four laws
- `Algebra.bend` — the proofs' algebra: verified Nat lemmas + Exp7/Dim lifting
- `PROOF.bend` — thin fillers delegating to `Algebra.bend`
- `RED.txt` / `GREEN.txt` / `REFACTOR.txt` — the checker transcripts
