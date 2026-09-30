# Stokes' theorem

**Statement:** for a region M with boundary ∂M and a form ω,

> ∫_M dω = ∫_{∂M} ω

The integral of dω over the region equals the integral of ω over the
region's *boundary*. Everything interior cancels pairwise — each interior face
is shared by two pieces with opposite orientation — so only the skin matters.

**One theorem, four classics:**

- k = 0: the **fundamental theorem of calculus** — ∫_a^b f'(x) dx = f(b) − f(a).
  The boundary of an interval is its two endpoints.
- k = 1: **Green's theorem** and the classical **Stokes' theorem** —
  circulation around a loop = total swirl inside.
- k = 2: the **[divergence theorem](divergence-theorem.md)** — flux through a
  closed surface = total source inside.

The Lean community has a sorry-free formalization of Stokes for singular cubes
(4,000+ lines); the [bend-packages#81](https://github.com/lilalittle/bend-packages/issues/81)
issue tracks the Bend version, with the discrete [divergence theorem](divergence-theorem.md)
as the first milestone.

**Why it matters here:** Stokes is the machine-checkable shape of "the inside
is determined by the skin" — the exact claim RCCM needs for its cavity-charge
story. See [the RCCM connection](rccm-connection.md).

## See also

- [The divergence theorem](divergence-theorem.md) — the k=2 case, first milestone
- [Boundary of a boundary](boundary-of-boundary.md) — why interior contributions cancel
- [d² = 0](d2-zero.md) — d applied twice vanishes; Stokes applied twice is empty
