# #76 Expressivity Probes — Results (2026-10-01; corrected 2026-10-01)

Toolchains: bend 2.0.27 (`~/.bend/bin/bend`, pinned); 2.0.34 candidate
(`~/workspace/bend-staging/bend-2.0.34/bend/bin/bend`). Unless noted, results
are from 2.0.27. Each probe records four fields: original question (unchanged
from the brief), checked result (exact declaration/scope), boundary
encountered (with reproducer), consequence (established / unknown / workaround).

Two corrections (2026-10-01) supersede overstated conclusions in the first
pass: probe1b reopens the dependent-evidence syntax with the documented
`@x:` form; probe3b isolates the Nat failure phase across five experiments.
Neither "templates only" nor "replace Nat" is an architectural requirement;
both exceeded the evidence. The public integer contract stays exact.

## Probe 1: Reusable Quantified Evidence

**Original question.** Can the proof fragment support reusable quantified
evidence — the hypothesis "for every input, these functions return equal
values," used repeatedly to prove finite sums equal by induction, with
evidence in erased proof positions? (Weaker than full function
extensionality: pointwise equality → finite-sum equality. Proving equality
of the function objects themselves is NOT required.)

**Checked result.** Mechanism PROVEN. `hyp_id` (hypothesis as proof term),
`hyp_rewrite` (hypothesis-driven `%` rewrite), and `sum_congr` (induction
over `n` reusing concrete top-level `f`, `g` via `~`-templates and applying
a concrete evidence generator `h` at each index) all check.

**Boundary encountered.** The first pass tried
`for -h: (x: Nat) -> {f(x) == g(x)}` and got a PARSE failure
(`expected: a defined name, observed: x`). That syntax was simply wrong —
see probe1b.

**Consequence.** The reuse mechanism works. The dependent-evidence binder
question was reopened with correct syntax in probe1b; the old "no quantifying
over functions" is retracted.

## Probe 1b: Dependent-Function Evidence (correction)

**Original question.** Does the documented dependent-function syntax
`@x: A -> B` (guide, type grammar; cf. Base's `Equal.cong` with
`for -f: A -> B`) support a quantified pointwise-evidence hypothesis?
Distinguish parse vs type-check vs quantity-check vs proof-check failure,
with exact errors. Test one application, then repeated use, then erasure,
separately.

**Checked result.** `one_app` — `for h: (@x: Nat -> {f(x) == g(x) : Nat})`,
goal `{f(0n) == g(0n)}`, proof `h(0n)` — CHECKS. `two_apps_tmpl` —
`for ~h: (...)` applied at two indices driving two rewrites — CHECKS.
`erased_plain_fn` (erased non-dependent function hypothesis, never applied)
CHECKS. All verified under 2.0.27 (`All terms check.`) and 2.0.34
(`ALL PROOFS CHECK`).

**Boundary encountered.**
- Plain `h` applied twice: QUANTITY failure —
  `expected: h / observed: h (consumed more than once)`. Functions are
  affine; a plain hypothesis function is single-use.
- `for +h: (...)`: KIND failure — `expected: Data / observed: Type`.
  `+` requires Data; function types are Type.
- Erased `-h` APPLIED as evidence (`h(0n)` or `% h(0n)`): ERASURE failure —
  `expected: -h / observed: h`. The binder parses, typechecks, and fills;
  application is what fails. Erased functions may appear in type/template
  positions (as Base's `Equal.cong` does with `-f`) but cannot be applied
  to produce evidence.

**Consequence.** Established: dependent pointwise evidence IS expressible;
repeated use goes through `~` (template); erased evidence functions cannot
be applied. Unknown: nothing material — the syntax question is resolved.
Workaround (if ever needed): template-based instances per function, as in
probe 1. Recorded position: the attempted wrong syntax failed;
general pointwise-evidence reuse is now demonstrated for `~`, unavailable
for applied `-h`.

## Probe 2: Equality Across Representations

**Original question.** Difference-pair equivalence + congruence, extended to
an explicitly modulated approximation-sequence example. No completeness
construction.

**Checked result.** PROVEN. `zadd_congr`, `zneg_congr` for
`(a,b)~(c,d) ≜ {a+d == c+b : Nat}`; `neg_preserves` carries approximation
evidence `p` (sequence `s`, modulus `M`) through `zneg` via
`zabs_diff_neg`. All check.

**Boundary encountered.** `%` rewrites are right-to-left only (flip with
`eq_sym`); a variable used twice in term position needs `+` (copyable), and
law fillers can't take `+`, so delegate to a helper def (this was the
`neg_preserves` blocker: `k (consumed more than once)`).

**Consequence.** Established: the equivalence + congruence pattern is
feasible with the r-to-l/`+`-helper discipline. Unknown/out of scope:
completeness (never attempted). No workaround needed.

## Probe 3: Mathematical/Runtime Arithmetic Contract

**Original question.** What integer arithmetic does the safe proof fragment
guarantee about runtime execution? Where is the boundary? (Brief noted a
2^48-1 native ceiling.)

**Checked result.** `nat_comm_provable` (Nat.add_comm proven from scratch —
not in Base), `u32_comm_available` (Base's verified U32.add_comm consumed),
`small_nat_comm_transfer` all check. Parser: Nat literals cap at 2^32-1
(`281474976710655n` → `expected: a nat literal up to 4294967295n`).

**Boundary encountered.** The first pass concluded "Nat is unary, therefore
executable work must not use Nat" and "execution is faithful only for small
values." Both exceeded the evidence: they conflated logical representation,
checker reduction, compiler lowering, and algorithm behavior. Corrected in
probe3b.

**Consequence.** The contract question is answered by probe3b's localized
boundary. The U32 laws are consumed as-is; no integer-to-modular substitution
is made (that would need a decoding refinement with explicit range
conditions, not established here).

## Probe 3b: Nat Failure-Phase Isolation (correction)

**Original question.** Localize the observed Nat stack overflow across five
phases: (a) large literal without traversal, (b) Base arithmetic at runtime,
(c) output formatting separately, (d) custom recursive operation,
(e) closed-equality normalization in the checker. Run relevant cases under
2.0.27 AND 2.0.34. Test mesh-cells vs coefficient-magnitude shapes.

**Checked result.** `checker_add_1k`, `checker_add_10k`
(`{Nat.add(10000n,1n) == 10001n}` via `{==}`) CHECK under both toolchains.
Full experiment transcript: `probe3b/TRANSCRIPT.md` (backend, command, input,
exit code, failure phase per experiment).

**Boundary encountered.** Pinned-source fact: Base's `Nat.add` is
NON-TAIL-recursive (`match a: case 1n+p: 1n+Nat.add(p, b)`, base.bend:545);
all `Nat.*` arithmetic in Base is similarly recursive. Measured:
- (a) Literal `4294967295n` accepted and printed correctly, both toolchains.
  Parse/elaboration/conversion/formatting are NOT the failure.
- (b) `Nat.add` at runtime overflows between 5000 and 10000 depth
  (1000/2000/5000 work; 10000 overflows), both toolchains.
- (d) Tail-recursive `countdown(100000n)` works — 100k depth fine. The limit
  is NON-TAIL recursion depth, not a "Nat ceiling."
- (e) The CHECKER normalizes the 10k-step `Nat.add` that the RUNTIME
  overflows on. Checker and runtime have different reduction limits.
- Mesh shapes: 1000 cells × 1n (tail-recursive loop, shallow adds) → `1000n`,
  both toolchains. One 1000000n coefficient → overflow. Cell count and
  coefficient magnitude are independent workloads.

**Consequence.** Established: this particular workload (`Nat.add` on a
~10k+ first argument) fails at this size through the runtime execution path,
via non-tail recursion depth in Base's definition — not via Nat's
representation, literals, formatting, or checker normalization. Unknown:
whether the compiler's w64 Nat lowering supplies primitive arithmetic paths
(not visible in base.bend; comp.ts not in the staging tree) — the compiled
arithmetic contract is unmeasured. Workaround: keep the exact public integer
contract; prefer tail-recursive/shallow definitions for large workloads;
optimize only a demonstrated bottleneck, with decoding laws proven first.
NOT established: "execution faithful only for small values" (resource
failure ≠ incorrect value — small cases returned correct values, and 100k
tail-recursive steps computed correctly).

## Probe 4: Generic Algebra + Repeated Field Evaluation

**Original question.** Can an algebraic identity be proven once and
instantiated at multiple concrete/symbolic points without copying proof
code?

**Checked result.** PROVEN. `nat_distr` (`a*(b+c) == a*b+a*c`) proven once
by induction on `a`; instantiated at (2,3,4), (5,6,7), and symbolic
(x,1,1) with zero proof-code duplication. Fillers are one-line applications.

**Boundary encountered.** The first pass marked "full abstraction over
arbitrary (add,mul) pairs BLOCKED by probe 1's finding" — that finding was
the wrong-syntax parse failure, now corrected by probe1b. Also discovered:
no forward references (define helpers before use); binder-free laws need
`def Laws.name():` fillers.

**Consequence.** Established: prove-once/instantiate-many works for
concrete instances. Reopened (not blocked): abstraction over operation
pairs, pending probe1b's quantification results. No architectural
"templates only" requirement follows — that would exceed the evidence.

## Probe 5: Array Refinement

**Original question.** Can proofs about fixed-size array computations be
stated and checked in the fragment?

**Checked result.** PROVEN. Dedicated `V2` product type with `dot2`:
`dot_eval` (`dot2(V2{2,3},V2{4,5}) == 23` by computation) and `dot_zero`
(`dot2(a,V2{0,0}) == 0` for variable `a` via `nat_mul_zero_r`) check.

**Boundary encountered.** `dot_comm` would need `nat_mul_comm` — a
substantial independent arithmetic development, not an array issue
(documented, not stated as a law). Base's `Array<T>` is a binary tree
(ALeaf/ANode), awkward for fixed-size vectors; product types are natural.

**Consequence.** Established: array reasoning composes on top of
element-operation laws. Algebraic properties of elements must be supplied
separately; that is a proof-obligation inventory, not a fragment limitation.

## Probe 6: Compositional Scaling

**Original question.** Do proven components compose as black boxes, and does
proof reuse scale to new compositions without new plumbing per instance?

**Checked result.** HOLD (composition demonstrated; scaling unmeasured).
`dot2(a, vec_add(b,c)) == dot2(a,b) + dot2(a,c)` proven by composing
`nat_distr` and `add_rearr` as black boxes — no reproving. Checks.

**Boundary encountered.** This composition required a handwritten rewrite
script: 3 explicit `%` steps (two `nat_distr` applications, one `add_rearr`
alignment) plus `eq_sym` direction flips. No composition tactic exists.

**Consequence.** Established: lemma composition works (one instance).
Unmeasured: scaling — three manual rewrites show possibility, neither good
scaling nor a permanent per-geometry handwriting requirement. The standing
automation direction is unchanged: prove a generic normalization or
linear-extension theorem once (handwritten rewrites inside it are fine),
then let new incidence data supply checked instances; repeating the script
per mesh is what the abstraction should remove.

## Checker Discipline (empirical, all verified)

1. `%` rewrites right-to-left only: `e : {l == r}`, `_` marks `r`-occurrences,
   replaced by `l`. Flip with `eq_sym` for the other direction.
2. In a `%` sequence, 2nd+ takes no space (`%e`, not `% e`) — else
   `expected: a term, observed: ':'`.
3. `%` needs a bare defined name: `%Laws.foo` fails
   (`expected: a defined name`); define unqualified wrappers in PROOF.bend.
4. Term-position variables are affine (use-once) unless `+` (copyable). Type
   positions allow free reuse. Law fillers can't take `+`; delegate to a
   helper def. Functions are affine: a plain hypothesis function is
   single-use; `~` (template) is reusable; `+` requires Data (kind error on
   function types).
5. Erased (`-`) function hypotheses: bindable and usable in type/template
   positions (cf. Base's `Equal.cong`), but not applicable as evidence
   (`expected: -h, observed: h`).
6. No forward references: define helpers before use.
7. Binder-free laws need `def Laws.name():` fillers (with parens).
8. Dependent function types use `@x: A -> B` (guide, type grammar) —
   `(x: A) -> B` is a parse error, not a logic limitation.

## Standing corrections

- The wrong-syntax parse failure is a syntax finding, not a logic
  limitation. Base ships `Equal.cong` quantifying over arbitrary functions.
- The Nat stack overflow is localized to non-tail recursion depth in Base's
  `Nat.add` at runtime (5k–10k frames). It is not a representation ceiling,
  not a checker limit, and not evidence of incorrect values.
- No "templates only" architecture and no Nat→U32 substitution follow from
  these probes. The integer contract stays exact; representation changes
  require demonstrated bottlenecks plus proven decoding laws.
- Probe sources, negative reproducers, commands, and transcripts:
  `playground/probes-76/probe{1..6,1b,3b}/`; probe3b's full experiment
  transcript is `probe3b/TRANSCRIPT.md`.
