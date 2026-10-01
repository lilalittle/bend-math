# Why Z/2 coefficients -- and why they are not enough

The playground first proves d² = 0 over **booleans** -- the field with two
elements, Z/2 -- instead of real numbers. Over Z/2, addition is XOR, and
crucially **x + x = 0 for every x**; subtraction *is* addition. The F2 proof
rests on one fact: every edge-difference appears twice and cancels.

## The conflation to unlearn

An earlier version of this note said Z/2 "tells the truth" and the transfer
to integers was automatic. That conflates two different cancellations:

- over Z/2: `x + x = 0` (every element is its own inverse);
- over Z: `x + (−x) = 0` (cancellation needs the *sign*).

These are not the same fact, and a proof using only the first does not
establish the second. The passage from F2 to signed coefficients is not a
structurally automatic upgrade -- it is a separate theorem with separate
proof obligations.

## The blind spot

Modulo two, a missing minus sign is **invisible**. If you flip one incidence
coefficient of the triangle's boundary -- writing
`d_bad[012] = [12]+[02]+[01]` instead of `[12]−[02]+[01]` -- every F2 test
still passes, because `+1` and `−1` are the same element mod 2. But over the
integers the second boundary is `2[2] − 2[0]`, a nonzero residual. The very
orientation errors that matter for signed flux and charge survive every
mod-2 test. A proof over F2 does not lift to Z or R merely because the
intended theorem also holds there.

## The signed milestone

`playground/signed-chains/` replaces the F2 foundation with signed chains
over exact integers (difference pairs, since Base has no signed type) and
proves, about the actual boundary constructors:

1. `d² = 0` on the triangle, over the integers;
2. **consistent-reorientation control**: reorienting a cell *and* updating
   the affected incidence maps consistently preserves the identity --
   a legitimate change of orientation must keep working;
3. **inconsistent-incidence mutant**: flipping one incidence coefficient
   *without* the consistency changes stays well-typed and produces a
   checked nonzero residual witness, `d₁d_bad[012] = 2[2]−2[0]`;
4. reducing that **same** signed construction mod 2 gives zero -- the
   defect is concealed in the mod-2 shadow, which is exactly the blind spot.

The triangle is the smallest diagnostic: `d[012] = [12]−[02]+[01]` with
`d[ij] = [j]−[i]`; the mutant changes only the middle coefficient, and
direct expansion gives the residual `2[2]−2[0]` -- nonzero in the free
integer chain group, zero mod 2.

Rule going forward: for every claim intended to transfer off F2, the
signed proof plus both controls (consistent reorientation passes,
inconsistent incidence has a checked residual) are required. The Boolean
implementation is a *specialization* of the signed construction -- the
mod-2 reduction of it -- not its foundation.

## See also

- [Signed chains](signed-chains.md) -- the milestone itself
- [d² = 0](d2-zero.md) -- the F2 original this supersedes for transfer claims
- [Differential forms](differential-forms.md) -- forms can take coefficients in any ring
- [What algebra is](algebra.md) -- Z/2 is the smallest field; XOR is its addition
