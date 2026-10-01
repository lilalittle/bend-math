# Discrete divergence theorem (rung 4, 🟢 GREEN → 🔵 REFACTOR)

**Status: 🟢 GREEN, 🔵 REFACTORED.** The law is proved; `bend PROOF.bend`
prints `All terms check.`

## The idea

The divergence theorem says: flux through a closed surface = total divergence
inside. The discrete version needs no analysis — on a cubical complex, `div`
of a 2-form on a cube is the XOR over its 6 faces, and summing over the cubes,
every interior face is incident to exactly 2 cubes, so its value appears twice
and cancels (x + x = 0 over Z/2). What survives is exactly the flux through
the outer boundary. Over Z/2 orientation is invisible, so "opposite
orientations cancel" becomes "the shared value appears twice" — the incidence
content is what's proved.

## The RGR story

**🔴 RED:** one law stated with `?TODO`; gate failed honestly
(`Error: 1 TODO found` — see RED.txt).

**🟢 GREEN:** the smallest non-vacuous instance — **two cubes sharing one face**
(one cube would be true by definition: div *is* the boundary flux). The whole
proof is the cancellation `(s+A)+(s+B) = A+B`, proved by case-splitting on the
shared face `s`: `False` computes away (`xor(False, v)` reduces to `v`), `True`
reduces to `¬A ⊕ ¬B = A ⊕ B`, a 4-case brute-force lemma. See GREEN.txt.

**🔵 REFACTOR:** the algebra lives in `Algebra.bend` (`xor_not_not`,
`shared_face_cancels`); `PROOF.bend` keeps only the thin filler that unfolds
`div_cube`/`boundary_flux` into the lemma's shape. Gate still green — see
REFACTOR.txt. The two lemmas are pure Z/2 algebra, independent of cubes —
candidates for a verified boolean-algebra package.

## The RCCM gap, as an open law

This rung's definition of done also asks for rccm#3's boundary gap expressed
as a law. Here it is, stated and honestly open:

> **OPEN LAW `rccm_boundary_check` (not yet formalizable here):** in RCCM's
> asymmetric-metric setting, with its definitions of cavity charge `Q(V)` and
> boundary flux `Φ(∂V)`, prove `{Q(V) == Φ(∂V)}` — i.e. run this folder's
> argument with RCCM's charge/flux in place of the Z/2 face-values.

It stays open because RCCM's charge and flux aren't Z/2 face-values — porting
them needs verified reals/integers (rungs 5+) and RCCM's own coupling
definitions. When those exist, this folder's proof is the template: state the
sum-over-cells, show the interior couplings cancel, read off the boundary.
That is the theory-gap-as-failing-law pattern the BHAG wants.

## Bend lessons (new)

- A law's definitional unfolding must match the helper's type *syntactically
  up to reduction*: `boundary_flux` as a flat 10-nest vs. grouped per-cube
  are equal by associativity but not definitionally — the filler only
  typechecks when the groupings line up. When in doubt, shape the spec's
  definitions to the proof's natural grouping.
- Case-splitting on one variable can beat rewriting: `s = False` closed by
  computation alone, no rewrite lemmas needed.

## Files

- `LAWS.bend` — the spec: `div_cube`, `boundary_flux`, the divergence law
- `Algebra.bend` — `xor_not_not` + `shared_face_cancels`
- `PROOF.bend` — the thin filler
- `RED.txt` / `GREEN.txt` / `REFACTOR.txt` — the checker transcripts
