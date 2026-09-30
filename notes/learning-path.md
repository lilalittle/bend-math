# Learning path

The curriculum: learn advanced mathematics and physics *as a side effect of
formalizing them*. Work each rung with [the RGR loop](rgr-loop.md) — red, green,
refactor — and let the issues below track the frontier.

**Rung 0 — where you already stand.** If your math background is computer
graphics and web work rather than textbooks, start with the frontend bridge:
[Mathematics, for a frontend engineer](frontend-math.md),
[what algebra is](algebra.md), [vectors and matrices](vectors-matrices.md),
[the mathematics inside CSS](css-math.md). You know more than you think —
it's just never been called by its real names.

1. **[d² = 0](d2-zero.md)** — exterior algebra, the seed of everything. Done:
   [`playground/d2-zero/`](../playground/d2-zero/).
2. **Vector calculus identities** — div(curl F) = 0, curl(grad f) = 0, over exact
   types. The algebraic core of field theory. Done:
   [`playground/vector-identities/`](../playground/vector-identities/) —
   discrete grad/curl/div over Z/2 on a triangle and tetrahedron, full RGR
   cycle; the algebra lemmas extracted to `Algebra.bend`. The 64-case
   brute force is honest motivation for proof automation.
   ([issue](https://github.com/lilalittle/bend-packages/issues/68))
3. **Physical dimensions and units** — dimensional analysis as type-checking.
   🔴 RED started: [`playground/units/`](../playground/units/) — dimensions as
   7-exponent SI vectors (num/den Nat pairs, `is Data`), four laws stated
   (`?TODO`), including (m/s)·s = m via a specified-but-unimplemented
   `dim_norm`. GREEN is the next session's work.
   ([issue](https://github.com/lilalittle/bend-packages/issues/69))
4. **[The divergence theorem](divergence-theorem.md)** (discrete) — what Stokes
   says, finitely. Turns the RCCM boundary gap into a failing law.
   ([issue](https://github.com/lilalittle/bend-packages/issues/84))
5. **Verified integers and rationals** — what numbers are, constructively.
   ([issue](https://github.com/lilalittle/bend-packages/issues/70))
6. **Linear algebra** — vector spaces, properly this time.
   ([issue](https://github.com/lilalittle/bend-packages/issues/71))
7. **Lorentz group** — special relativity's algebra, ported from PhysLean.
   ([issue](https://github.com/lilalittle/bend-packages/issues/85))
8. **Verified real numbers** — the deepest node. What reals actually are.
   ([issue](https://github.com/lilalittle/bend-packages/issues/77))
9. **Real analysis** — limits to the fundamental theorem of calculus.
   ([issue](https://github.com/lilalittle/bend-packages/issues/79))
10. **Tensor calculus → differential geometry** — the language GR is written in.
    ([issues](https://github.com/lilalittle/bend-packages/issues/80),
    [issue](https://github.com/lilalittle/bend-packages/issues/81))
11. **ODE/PDE solvers, special functions** — applied analysis.
    ([issue](https://github.com/lilalittle/bend-packages/issues/74),
    [issue](https://github.com/lilalittle/bend-packages/issues/82))
12. **Proof automation, CAS-lite, theory-graph** — proof engineering, the
    tooling the earlier rungs will have demanded into existence.

Rule of the path: never climb before the rung below is solid. Each issue's
*Blocked by* section enforces it mechanically — walk any issue's blockers down
to a leaf and start there.

Full issue graph: [bend-packages#66](https://github.com/lilalittle/bend-packages/issues/66).
