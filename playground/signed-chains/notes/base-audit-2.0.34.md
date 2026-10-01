# Bounded Base audit: Bend 2.0.27 → 2.0.34 (for the signed-chains corpus)

Date: 2026-10-01. Auditor: North (subagent). Toolchains: pinned `~/.bend`
(2.0.27) and staged `~/workspace/bend-staging/bend-2.0.34/bend` (2.0.34).

## Scope

This audit is deliberately bounded, per Tom's direction: only changed
definitions **reachable from the signed-chains corpus** (`LAWS.bend` /
`PROOF.bend`), plus the native implementations those definitions depend
on. The full Base diff is 788 lines, concentrated in IO/TCP/UDP/Window,
effects, `Bool.full_add`, ordering-match refactors, `List.sort`,
`F32`/`Char`/`String`/`Map`/`Array` rewrites, and `Nat.read` — the corpus
touches almost none of it.

## Method

1. Diffed `bend2/base.bend` (2.0.27) against `bend2/base.bend` (2.0.34).
2. Enumerated the corpus's Base surface by counting qualified references
   in `LAWS.bend` + `PROOF.bend`.
3. For each reachable changed definition: read both implementations,
   judged whether the corpus's usage is affected.
4. Conversion change: tested with fixtures (equal shared structures,
   deliberately unequal structures with a deep differing leaf, and a
   large shared term) on **both** toolchains.
5. `U32.to_nat` native change: ran an executable boundary fixture on
   **both** toolchains (runtime semantics, kept separate from checking).
6. Kernel: recorded the actual `--verdict` behavior on this VM.

## 1. The corpus's Base surface is unchanged

Exact qualified references in the corpus (`LAWS.bend` + `PROOF.bend`):

| Definition | Uses | 2.0.27 → 2.0.34 |
|---|---|---|
| `Nat.add` | 44 | byte-identical |
| `Nat.is_eq` | 7 | byte-identical |
| `Bool.not` | 4 | byte-identical |
| `Bool.and` | 4 | byte-identical |
| `Bool.xor` | 1 | byte-identical |

All five definitions the proofs actually invoke are **byte-identical**
between the two `base.bend` files. The 788-line diff touches none of
them. Whatever else changed in Base, the corpus's checking surface did
not.

## 2. Changed and reachable: `Nat.read` (literal parsing)

`Nat.read` is reachable from every `0n`/`1n`/`2n` literal in the corpus.
It was restructured between versions:

- 2.0.27: `Nat.read.go` + `Nat.read.if`, with `Nat.read.max` /
  `Nat.read.fit` bounding the accumulator.
- 2.0.34: same `go`/`if` core, plus a pre-gate — `Nat.read.trim`
  (strip leading zeros), `Nat.read.fits` (fewer than 15 digits fit;
  exactly 15 compare lexicographically against `"281474976710655"`),
  `Nat.read.gate` (run the digit loop only if the string fits).

The new comment is explicit about the reason: 2^48-1 is the largest
native immediate, and reading a string that does not fit would build a
Nat past the bound. The gate only *refuses* oversized inputs (returning
`None`); for inputs that fit, the digit loop is the same
accumulate-`10n*acc+d` recursion.

**Verdict: behavior-preserving for the corpus.** The corpus's literals
are `0n`, `1n`, `2n` — single digits, far under any bound, unaffected
by the trim/fits/gate pre-check. No proof in the corpus reads a Nat
from a string at all; literals go through the compiler's literal path,
and the small values involved cannot distinguish the two
implementations.

## 3. Conversion changed in a soundness-critical implementation path

Framing, per Tom: *conversion changed in a soundness-critical
implementation path; verify that intended judgments and theorem
meanings are preserved.* Not "checking means something different" —
the judgments are the same; the implementation that decides them is
new (shared-graph conversion, 2.0.33: "two copies of one term are
equal before either unfolds").

Fixtures in `notes/fixtures/`, each run on **both** toolchains:

| Fixture | What it tests | 2.0.27 | 2.0.34 |
|---|---|---|---|
| `conv_equal_shared.bend` | `{inject(30n,0n) == inject(30n,0n)}` — equal shared structures | PASS (rc=0) | PASS (rc=0) |
| `conv_equal_copies.bend` | `{tower(20n) == tower(20n)}` — two copies of one term, ~2^20 nodes as a tree | **stack overflow** (rc=1, 1.64s) | **PASS** (rc=0, 0.28s) |
| `conv_unequal_deep.bend` | `{inject(30n,0n) == inject(30n,1n)}` — identical except one leaf at depth 30 | REJECT (rc=1) | REJECT (rc=1) |
| `conv_unequal_shallow.bend` | `{0n == 1n}` — sanity | REJECT (rc=1) | REJECT (rc=1) |

Findings:

- **Faster acceptance is real and measured.** `tower(20n)` equality
  kills 2.0.27 (stack overflow unfolding ~2^20 nodes) and passes on
  2.0.34 in 0.28s. The 2.0.33 "massive speedups" claim reproduces on
  this exact shape.
- **Rejection is preserved, including at depth.** The new conversion
  correctly rejects `unequal_deep`: a single differing leaf at depth 30
  inside otherwise-identical shared structure is still distinguished.
  Acceptance is faster, not looser — the fixtures test rejection
  behavior, not just faster acceptance.
- **Judgments agree on every fixture.** Both toolchains accept the same
  equalities and reject the same inequalities. Intended theorem meanings
  are preserved across the conversion change, on the shapes tested.

Boundary: these fixtures cover first-order Nat equalities with sharing.
They do not probe conversion under binders or the fuel-limited large
shared-graph case from the release notes (which concerns one large
proof, not the corpus's small ones — not extrapolated here).

## 4. `U32.to_nat`: native widening fix, runtime semantics preserved

`U32.to_nat` is **byte-identical** in both `base.bend` files — the 2.0.33
widening fix is in the native lane (the compiled `U32` operations), not
in Base source. Runtime semantics are therefore separate from
proof-checking semantics, and must be tested by execution, not by
`bend PROOF.bend`.

Executable boundary fixture `notes/fixtures/u32_to_nat_boundary.bend`,
run on **both** toolchains:

```
to_nat(0)      = 0              to_nat(2^31)   = 2147483648
to_nat(1)      = 1              to_nat(2^32-2) = 4294967294
to_nat(2^31-1) = 2147483647    to_nat(2^32-1) = 4294967295
```

**Byte-identical output on both toolchains.** The native widening fix
does not change observable `U32.to_nat` results at any boundary value
(0, 1, 2^31-1, 2^31, 2^32-2, 2^32-1).

## 5. Kernel status (this VM, 2026-10-01)

`--verdict` exists in 2.0.34 and now executes: Lean v4.34.0 is installed
(`~/.elan`, toolchain `leanprover--lean4---v4.34.0`, present since
~03:08 UTC 2026-10-01). Verified:

- `bend PROOF.bend --verdict` on the corpus: `ALL PROOFS CHECK`,
  exit 0, stable across runs.
- `--verdict` on a deliberately false proof: exit 1, `SOME PROOFS FAIL`
  with the type error — the kernel genuinely rechecks; it is not a
  rubber stamp.

The candidate profile's kernel expectation is therefore: flag present;
kernel runs when Lean v4.34.0/BendTT is in the environment, else the
honest classification is TOOL/RESOURCE FAILURE (environment gap) —
never a flattened capability verdict. The candidate fixtures
(`tests/run_candidate_tests.sh`) assert this: positive shows
ordinary=PASS + kernel=PASS (exit=0) on this VM.

## 6. Out of scope (flagged, not audited)

- Removed laws (`Array.swap.go`, `Array.get.go`, `Map.get.go`,
  `Map.set.go`, `Map.go`, `Map.is_empty.go`, `Map.del.go`): not reachable
  from the corpus; flagged for any future corpus that uses them.
- `Bool.full_add` restructure, `Nat.div.fin`/`Nat.mod.fin` removal,
  `Word.add_comm.arm` argument reorder, `U32.log2/div/mod/min/max`
  rewrites, `F32`/`Char`/`String`/`Map`/`Array` rewrites, `List.sort`,
  IO/TCP/UDP/Window/effects changes: not reachable; out of scope.
- The fuel-limited large shared-graph conversion case from the 2.0.33
  notes: not exercised (concerns one large proof, not the corpus).

## 7. A note on staying on the old pin

Staying on 2.0.27 preserves the old behavior, and that is exactly what
a pin is for: **reproducibility**. It is not evidence the older
implementation is more correct. The conversion fixtures above show the
new implementation deciding the same judgments on the tested shapes —
faster, and still rejecting what it should reject. The pin decision
remains Tom's; this audit only bounds what the Base changes mean for
the corpus.

## Bottom line

- The corpus's checking surface (`Nat.add`, `Nat.is_eq`, `Bool.not`,
  `Bool.and`, `Bool.xor`) is byte-identical across the upgrade.
- The one reachable changed definition (`Nat.read`) is
  behavior-preserving for the corpus's small literals.
- The conversion change preserves intended judgments on the tested
  shapes: equal shared structures accepted (one dramatically faster),
  unequal structures — including a deep differing leaf — still rejected.
- `U32.to_nat` executes identically on both toolchains at every
  boundary value.
- No Base change found that alters what the corpus's proofs mean.
