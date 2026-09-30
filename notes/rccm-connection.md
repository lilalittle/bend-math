# The RCCM connection

**The mission:** make the Bend package ecosystem robust enough that speculative
theoretical physics can be formalized without inventing new packages —
[bend-packages#65](https://github.com/lilalittle/bend-packages/issues/65).

**The motivating example:** RCCM, a theory of cavity charge built on an
asymmetric metric tensor, with an existing law-driven formalization
([subtleGradient/rccm](https://github.com/subtleGradient/rccm)). Its open gap —
[rccm#3](https://github.com/subtleGradient/rccm/issues/3) — is a boundary
story: the theory claims cavity charge *is* enclosed flux, but the
formalization can't yet state the check that would verify it.

**Why these notes exist:** that check is the [divergence theorem](divergence-theorem.md) —
flux through the skin equals stuff inside — which is [Stokes' theorem](stokes-theorem.md)
at k = 2, which stands on [d² = 0](d2-zero.md). The garden climbs the dependency
chain from the bottom: every note is a rung between "I want to formalize this
physics" and "the machine agrees."

**The concrete bridge:** [bend-packages#84](https://github.com/lilalittle/bend-packages/issues/84)
(the discrete divergence theorem) is blocked only by d² = 0 and the vector
calculus identities. Finish those two approachable leaves and rccm#3 turns from
prose into a *failing law* — the exact theory-gap-as-failing-law pattern the
mission wants.

## See also

- [The divergence theorem](divergence-theorem.md) — the check rccm#3 needs
- [d² = 0](d2-zero.md) — the first rung, proved
- [Learning path](learning-path.md) — the climb, in order
- [The RGR loop](rgr-loop.md) — how each rung gets worked
