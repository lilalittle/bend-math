# The divergence theorem

**Statement:** for a volume V with closed boundary surface S and a vector field F,

> flux of F through S = total divergence of F inside V

Add up everything *produced* inside the volume; it must all exit through the
skin. A faucet inside a bubble: water out through the skin equals water from
the faucet. No faucet, no net outflow — a uniform current enters one side and
leaves the other.

This is [Stokes' theorem](stokes-theorem.md) at k = 2, and it's the workhorse
of physics: Gauss's law (charge inside = electric flux through the surface),
fluid continuity, heat flow. Whenever a theory says "the enclosed X is the
flux through the boundary," it's saying the divergence theorem.

**The discrete version** — the same statement on a cubical complex, with sums
instead of integrals and no analysis at all — is the target of
[bend-packages#84](https://github.com/lilalittle/bend-packages/issues/84).
It builds directly on [d² = 0](d2-zero.md) and the
[vector calculus identities](https://github.com/lilalittle/bend-packages/issues/68):
once those are proved, the discrete divergence theorem is the natural next
green. And it's the formal shape of [the RCCM boundary gap](rccm-connection.md).

## See also

- [Stokes' theorem](stokes-theorem.md) — the general statement
- [Gradient, curl, divergence](gradient-curl-divergence.md) — divergence's definition
- [The RCCM connection](rccm-connection.md) — the human story this unblocks
