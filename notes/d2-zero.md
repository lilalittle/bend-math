# d² = 0

**Statement:** applying the [exterior derivative](exterior-derivative.md) twice
always gives zero: d(dω) = 0 for every form ω.

**Why it's true:** [the boundary of a boundary is empty](boundary-of-boundary.md).
d measures change around boundaries; d² measures change around the boundary of
a boundary — which doesn't exist. Every contribution appears twice with
opposite orientation and cancels.

**In the playground:** [`playground/d2-zero/`](../playground/d2-zero/) proves
the smallest non-vacuous instance — a single triangle, [Z/2 coefficients](z2-coefficients.md).
A 0-form is three booleans (a, b, c) on the vertices; d puts XOR-differences on
the edges; d of that on the face is the XOR of the three edge values. The proof
is 8-case brute force: in every case each difference appears twice and
cancels, because x + x = 0.

**What it unlocks:** d² = 0 is what makes *chain complexes* work — sequences of
spaces linked by d where "cycles mod boundaries" becomes a well-defined thing.
That quotient is *cohomology*, the machinery that detects holes in spaces
(a loop around a hole is a cycle that isn't any patch's boundary). The
[vector calculus identities](https://github.com/lilalittle/bend-packages/issues/68)
— curl grad = 0, div curl = 0 — are d² = 0 in disguise.

## See also

- [Boundary of a boundary](boundary-of-boundary.md) — the geometric heart
- [The exterior derivative](exterior-derivative.md) — the operator being squared
- [Gradient, curl, divergence](gradient-curl-divergence.md) — d² = 0's classical faces
- [Why Z/2 coefficients](z2-coefficients.md) — why booleans suffice for the first proof
