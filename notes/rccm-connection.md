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
(the discrete divergence theorem) was blocked only by d² = 0 and the vector
calculus identities — both now proved, and #84 with them
([`playground/divergence-theorem/`](../playground/divergence-theorem/): two
cubes sharing a face, the shared face cancelling out of the summed
divergences). So rccm#3's prose now has a precise open law to aim at,
`rccm_boundary_check`: with RCCM's definitions of cavity charge `Q(V)` and
boundary flux `Φ(∂V)`, prove `{Q(V) == Φ(∂V)}` — the discrete proof is the
template (sum over cells, interior couplings cancel, read off the boundary).
It stays open because RCCM's charge/flux aren't Z/2 face-values: porting them
needs verified numbers (rungs 5+) and RCCM's own coupling definitions. The
theory-gap-as-failing-law pattern now has its first concrete instance.

## See also

- [The divergence theorem](divergence-theorem.md) — the check rccm#3 needs
- [d² = 0](d2-zero.md) — the first rung, proved
- [Learning path](learning-path.md) — the climb, in order
- [The RGR loop](rgr-loop.md) — how each rung gets worked
