# Signed chains

The milestone that replaces "Z/2 tells the truth" with something checked:
`playground/signed-chains/`.

## What it is

Chains on the triangle (vertices {0,1,2}, oriented edges {01,02,12}, one
face [012]) with coefficients in **exact integers**. Bend 2.0.27's Base has
no signed integer type, so integers are difference pairs `(pos, neg)`
denoting `pos − neg` -- the same num/den pair pattern as the units
playground. Since equality of representatives is not integer equality
(`(3,3)` and `(0,0)` both denote 0), chain laws go through the decidable
zero test `z_is_zero`, never bare syntactic equality of integer terms.

## What is proved

About the actual boundary constructors (`b1`, `b2` -- never assumed):

- **`boundary_squared_zero`**: `d² = 0` on the triangle, over the integers.
- **`reorient_consistent`**: flipping edge 01 to 10 *and* negating the
  affected incidence column preserves the identity. A legitimate
  orientation change must keep working -- this control distinguishes a
  consistent reorientation from a sign error.
- **`mutant_residual_exact` / `mutant_residual_nonzero`**: the inconsistent
  mutant `d_bad[012] = [12]+[02]+[01]` stays well-typed and yields the
  checked residual `d₁d_bad[012] = 2[2]−2[0]`, provably nonzero.
- **`mutant_vanishes_mod2`**: the mod-2 reduction map (`z_parity`) applied
  to that *same* signed chain gives zero. The defect is concealed mod 2 --
  the blind spot, demonstrated rather than asserted.

## How it is proved

The five laws close by checked computation (normalization): each goal is a
closed term the checker reduces. No case-splitting over assignments
anywhere -- the exponential-enumeration architecture is gone. (Checked
normalization is an accepted route here; the criterion is eliminating
enumeration, and structural induction remains available for the general
machinery.)

The reusable core is `Algebra.bend`, which imports only Base: the `Z`
group laws (`zadd_comm`, `zadd_assoc`, `zadd_zero_r`, `zneg_invol`, and
the cancellation lemma `zadd_neg_zero`: `x + (−x)` denotes zero) proved by
structural induction over the Nat lemmas. Dependency direction is
spec → algebra: `LAWS.bend` imports `Algebra.bend`, never the reverse.
The triangle is this algebra's first consumer; the second geometry must
consume the same definitions and lemmas without copying proof code --
that is the next delivery's acceptance test for the shared abstraction.

## The one command

`playground/signed-chains/verify.sh`: prints pinned toolchain identifiers
(bend 2.0.27, `base.bend` sha256), the ordinary gate result, and the
kernel-check result separately. `--verdict` does not exist in 2.0.27, so
the kernel check is recorded as **unsupported**, never as passed.

## See also

- [Why Z/2 coefficients -- and why they are not enough](z2-coefficients.md)
- [The RGR loop](rgr-loop.md)
- [Learning path](learning-path.md) -- rung status
