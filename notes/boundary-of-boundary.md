# Boundary of a boundary

Take a patch — say, a triangle. Its **boundary** is the rim: three edges with
a direction of travel. Now take the boundary *of that rim*: the endpoints of
the edges. Each vertex of the triangle is the end of one edge and the start of
the next — every vertex appears **twice**, once with each orientation, and they
cancel. The boundary of a boundary is empty: **∂∂ = 0**.

This isn't a deep theorem; it's *counting*. Walk the rim and come back to
start: every step out is matched by a step in. Nothing is left over.

[d² = 0](d2-zero.md) is the analytic twin of this geometric fact. d measures
change around boundaries; applying it twice measures change around the
boundary *of* a boundary — which is empty, so the answer is always zero.

Stokes' theorem (∫_M dω = ∫_{∂M} ω) is the same idea wearing an integral:
integrating dω over a region only ever sees the region's boundary, because
interior contributions cancel pairwise — each interior face is counted twice,
once from each side.

## See also

- [d² = 0](d2-zero.md) — the algebraic statement, machine-checked
- [The exterior derivative](exterior-derivative.md) — d, which measures change around boundaries
- [Stokes' theorem](stokes-theorem.md) — where the pairwise cancellation does its work
