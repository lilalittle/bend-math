# Delivery 2 Notes — Signed Core (2026-10-01)

## What works

**Core.bend** (all terms check):
- `Z` as difference pairs `ZC{p,n}`, exact integer arithmetic.
- `zmul`, `zadd`, `zneg`, with lemmas: `zmul_one_r`, `zmul_neg_one_r`,
  `zadd_neg_zero`, `zscale_zero_pp` (no boolean reflection — uses
  `nat_is_eq_refl` on syntactic `(p,p)`).
- Nested-`zmul` simplification helpers (`zmul_zmul_11`, `_1n`, `_n1`, `_nn`):
  prove `zmul(zmul(a,±1),±1)` reduces without associativity.
- `Chain`, `Table`, `lookup`, `chain_scale`, `chinsert`, `chain_add`,
  `boundary` (combining via `chain_add`), `chain_is_zero`.
- The combining boundary computes correctly: double boundary of the
  triangle face gives syntactic `(1,1)` coefficients.

**triangle/cell_closed** (PROVEN):
- Law: `for cell:Nat, for a:Z, {chain_is_zero(boundary(t_tri, scale(a, lookup(t_tri,cell)))) == True}`.
- Proved by case analysis: cells 0-5 by `{==}` (empty or definitional),
  cell 6 (face) by 9 explicit rewrites using the nested-zmul helpers
  + `zadd_neg_zero`, cells `7n+k` by `{==}` (lookup computes to `[]`).
- The `7n+k` pattern handles the infinite default case — the checker
  can see `Nat.is_eq(i, 7+k) = False` for concrete `i`.

## Blocker: generic b2_step is unprovable

**The problem**: The reusable induction step
```
b2_step(t, cell, a, rest, ih, cp) : {chain_is_zero(B(B(CCons{cell,a,rest}))) == True}
```
requires two lemmas that are unprovable in Bend 2.0.27:

1. **`boundary_add`**: `boundary(t, chain_add(X,Y)) = chain_add(boundary(t,X), boundary(t,Y))`.
   - The combining `boundary` does NOT distribute over `chain_add`.
   - The needed `boundary_chinsert` lemma
     (`boundary(t, chinsert(e,x,Z)) = chinsert(e,x,boundary(t,Z))`)
     is **FALSE** in general: `chinsert` combines at the chain level,
     but `boundary` distributes scalars into the lookup chains.
   - Counterexample sketch: `Z=[(e,y)]`, `chinsert(e,x,Z)=[(e,x+y)]`,
     `boundary` of this scales by `(x+y)`, but `chinsert(e,x,boundary(Z))`
     inserts `x` alongside the already-scaled `y` terms — different structure.

2. **`chain_is_zero_add`**: from `{z_is_zero(x)==True}`, `{z_is_zero(y)==True}`,
   prove `{z_is_zero(zadd(x,y))==True}`.
   - This is **boolean reflection**, which Bend 2.0.27 does not support.
   - From `{Nat.is_eq(xp,xn)==True}` you cannot extract `xp=xn`.
   - Confirmed empirically: no explosion from `{False==True}`.

**Root cause**: The combining boundary was chosen so that closed double
boundaries compute to syntactic `(p,p)` (needed for `zscale_zero_pp`).
But combining BREAKS the linearity that the induction step needs.
There is a fundamental tension:
- Combining boundary → syntactic `(p,p)` → `cell_closed` provable.
- Combining boundary → NOT linear → `b2_step` unprovable.

**ZeroChain approach** (explored in /tmp/probe):
- Defined `ZeroChain` (explicit syntactic `(p,p)`), `to_chain`, `zchain_add`,
  proved `to_chain_add` (to_chain preserves zchain_add) via Bool case analysis
  on the `pick` condition.
- This solves the `chain_is_zero_add` problem (syntactic, not boolean).
- But `b2_step` STILL needs `boundary_add`, which is false for combining boundary.

## Path forward (options)

**Option A**: Non-combining boundary + syntactic normalization.
- Change `boundary` to use `chain_append` (provably linear).
- Define `chnorm : Chain -> ZeroChain` (or similar) that combines to
  syntactic `(p,p)` form.
- Theorem: `{to_chain(chnorm(B(B(c)))) == ...}` or similar.
- The `cell_closed` proof becomes harder (must handle duplicates).

**Option B**: Per-geometry B² without generic step.
- Each geometry proves `b2` by induction, doing the combining reasoning
  concretely (like `cell_closed` does). No reusable `b2_step`.
- This is "geometry-specific proof architecture" — the task says to
  report this as abstraction failure if needed.

**Option C**: Weaken the reusable theorem.
- The reusable part is `cell_closed` (per-cell, proven) + the *statement*
  that B²=0 extends linearly. The *proof* of extension is per-geometry.
- Honest but does not meet "one universal linear-extension theorem".

## Recommendation

The combining-boundary design cannot support a provable generic `b2_step`
in Bend 2.0.27. The `cell_closed` result (arbitrary coefficients, no
enumeration) is the substantive achievement. I recommend Option A
(redesign with linear boundary + syntactic normalization) if the universal
theorem is required, or Option B with explicit acknowledgment if delivery
pressure favors it.
