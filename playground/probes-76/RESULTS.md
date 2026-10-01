# #76 Expressivity Probes — Final Results (2026-10-01, bend 2.0.27)

All probes: `bend PROOF.bend` → "All terms check."

## Probe 1: Reusable Quantified Evidence — PROVEN (mechanism) / BLOCKED (generality)
- Hypothesis-as-proof-term, hypothesis-driven `%` rewrite, and induction proving
  finite-sum congruence with `~`-template function application all check.
- BLOCKED: `for -h: (x: Nat) -> {f(x) == g(x) : Nat}` is a parse error
  (`expected: a defined name, observed: x`). Bend 2.0.27 `for` binders cannot
  express dependent function types.
- Design rule: reusable theorems use concrete top-level functions + `~`-templates,
  instantiated per function. No universally-quantified-over-functions law.

## Probe 2: Equality Across Representations — PROVEN
- `zadd_congr`, `zneg_congr` for difference-pair equivalence `(a,b)~(c,d) ≜ a+d==c+b`.
- `neg_preserves`: approximation evidence `p` carried through `zneg` for a
  sequence with modulus. Uses `zabs_diff_neg` (simultaneous-negation symmetry).
- Key fixes: `%` rewrites right-to-left only (flip with `eq_sym` for the other
  direction); `+` (copyable) params needed when a variable is used twice in term
  position (law fillers can't take `+`, so delegate to a helper).

## Probe 3: Mathematical/Runtime Arithmetic Contract — PROVEN (with boundary)
- Parser: Nat literals capped at 2^32-1 (`281474976710655n` → parse error).
  The "2^48-1 native ceiling" is not reachable via literals.
- Runtime: Nat is unary (Peano). `Nat.add(4294967295n, 1n)` → stack overflow.
  Practical ceiling ~10^4–10^5 (10000n works, 100000n overflows).
- Base ships `U32.add_comm` (verified) but NOT `Nat.add_comm`/`Nat.add_assoc`
  (proven manually here). F32 ops are axioms.
- Contract: proofs are about mathematical (unbounded) Nat; runtime execution is
  faithful only for small values. `nat_comm_provable`, `u32_comm_available`,
  `small_nat_comm_transfer` all check.

## Probe 4: Generic Algebra + Repeated Field Evaluation — PROVEN
- `nat_distr` (distributivity) proven ONCE by induction on `a`.
- Instantiated at (2,3,4), (5,6,7), and (x,1,1) with zero proof-code duplication.
- Full abstraction over arbitrary (add,mul) pairs BLOCKED by probe 1's finding.
- Discovered: no forward references (define helpers before use); binder-free laws
  need `def Laws.name():` fillers.

## Probe 5: Array Refinement — PROVEN
- V2 fixed-size vector type; `dot2` dot product.
- `dot_eval`: `dot2(V2{2,3}, V2{4,5}) == 23` by computation. ✓
- `dot_zero`: `dot2(a, V2{0,0}) == 0` for variable `a` via `nat_mul_zero_r`. ✓
- Boundary: `dot_comm` would need `nat_mul_comm` (substantial independent
  arithmetic development, not an array issue). Algebraic properties of element
  operations must be supplied separately; array reasoning composes on top.
- Base's `Array<T>` is a binary tree (ALeaf/ANode) — awkward for fixed-size
  vectors; dedicated product types are the natural representation.

## Probe 6: Compositional Scaling — PROVEN
- `dot2(a, vec_add(b,c)) == dot2(a,b) + dot2(a,c)` proven by composing
  `nat_distr` and `add_rearr` as black boxes (no reproving).
- Plumbing required: 3 explicit `%` rewrites (two `nat_distr` applications, one
  `add_rearr` alignment) plus `eq_sym` flips for direction. Composition works,
  but the connections are manual equational steps, not automatic.

## Checker Discipline (empirical)
1. `%` rewrites right-to-left: `e : {l == r}`, `_` marks `r`-occurrences, replaced by `l`.
2. For left-to-right, flip with `eq_sym` first.
3. In a `%` sequence, 2nd+ must have no space (`%e`, not `% e`).
4. `%` needs a bare defined name: `%Laws.foo` fails; wrap unqualified in PROOF.bend.
5. Term-position variables are affine (use-once) unless `+` (copyable). Type
   positions allow free reuse. Law fillers can't take `+`; delegate to helpers.
6. No forward references: define before use.
7. Binder-free laws: `def Laws.name():` (with parens).
