# Signed chains on the triangle

The signed-coefficients milestone (bend-packages#67): the F2-only proofs in
`d2-zero/` and `vector-identities/` cannot see orientation-sign errors --
modulo two, a flipped incidence sign is invisible. This slice replaces the
F2 foundation with **signed chains over exact integers** for the smallest
diagnostic, the triangle, plus two controls.

## The construction

Bend 2.0.27 Base has no signed integer type, so `Algebra.bend` defines one:
integers as difference pairs `(pos, neg)` denoting `pos - neg` (the same
num/den pair pattern as `playground/units`). Equality of representatives is
*not* integer equality -- `(3,3)` and `(0,0)` both denote 0 -- so chain laws
go through the decidable zero test `z_is_zero`, never bare syntactic
equality of `Z` terms.

`Algebra.bend` imports **only** Base -- never `LAWS.bend`. The dependency
points from this spec into the algebra, not the reverse. Its Part 3 proves
the `Z` group laws structurally (induction + rewriting, zero enumeration):
`zadd_comm`, `zadd_assoc`, `zadd_zero_r`, `zneg_invol`, and the cancellation
lemma `zadd_neg_zero` (`x + (-x)` denotes zero). The triangle complex in
`LAWS.bend` is this algebra's first consumer; the second geometry (next
delivery) must consume the same definitions and lemmas without copying
proof code.

`LAWS.bend` builds the triangle complex: vertices {0,1,2}, oriented edges
{01,02,12}, one face [012], with `b2` (`d[012] = [12]-[02]+[01]`) and `b1`
(`d[ij] = [j]-[i]`, linearly extended) as the **actual constructors** --
`boundary_squared_zero` is proved *about* them, never assumed as an input.

## The five laws

| Law | Content |
|---|---|
| `boundary_squared_zero` | `d² = 0` on the triangle, over the integers |
| `reorient_consistent` | (a) consistently reorienting edge 01→10 (negating both the face coefficient and the 1-boundary's first column) preserves the identity |
| `mutant_residual_exact` | (b) the inconsistent mutant `d_bad[012] = [12]+[02]+[01]` gives exactly `2[2]−2[0]` |
| `mutant_residual_nonzero` | (b) checked nonzero-residual witness: the residual is *not* the zero chain (well-typed, no timeout -- the checker confirms nonzeroness) |
| `mutant_vanishes_mod2` | (c) reducing the **same** signed chain `b1(b2_bad)` coefficient-wise mod 2 gives zero -- the defect is concealed in the mod-2 shadow |

(c) is the blind-spot demonstration, and it is proved by applying the
mod-2 reduction map (`z_parity`: `parity(p-n) = parity(p) XOR parity(n)`)
to the same signed construction -- not by a separately implemented Boolean
example. The connection between the signed construction and its mod-2
shadow is established, not assumed.

## RGR log

- **RED**: five laws stated with `?TODO` → `Error: 5 TODOs found.` (`RED.txt`)
- **GREEN**: all five close by checked computation/normalization -- no
  case-splitting over assignments anywhere (`GREEN.txt`). Checked
  normalization is the accepted route here; the acceptance criterion is
  eliminating the exponential-enumeration architecture, and none of these
  proofs enumerate.
- **REFACTOR**: `Z` arithmetic extracted to standalone `Algebra.bend` with
  the group laws proved structurally; `LAWS.bend` imports it qualified
  (`Alg.`). Negative-tested: corrupting a lemma statement fails the gate
  at `Algebra.zadd_neg_zero`, so the imported module is genuinely checked.
  (`REFACTOR.txt`)

## Reproduce

Run `./verify.sh` from this directory. It prints the pinned toolchain
identifiers, the ordinary gate result, and the (unavailable) kernel-check
result separately -- never flattened into a single "verified".

## See also

- `notes/signed-chains.md`, `notes/z2-coefficients.md` -- the blind spot
- `notes/learning-path.md` -- rung status
- bend-packages#67 (d²=0), #84 (discrete divergence theorem, next consumer)
