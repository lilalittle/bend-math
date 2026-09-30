# bend-math

Executable mathematics in Bend 2, guarded by machine-checked proofs.

## Files

- `Expr.bend` — the math itself: symbolic expressions (`Cst | Var | Add | Mul`),
  an evaluator `eval`, a symbolic differentiator `diff`, and a forward-mode
  automatic-differentiation evaluator `evald`. All of it *runs* — this is code,
  not notation.
- `LAWS.bend` — the spec, written for humans. `diff_correct` states that
  forward-mode AD (`evald` with dx=1) always agrees with symbolic
  differentiation (`diff`, then `eval`). Refactor the code however you like;
  this law must keep holding.
- `PROOF.bend` — the machine-checked proof of the law, by structural induction
  on expressions. `bend PROOF.bend` is the gate: it prints `All terms check.`
  only while every law holds. A broken refactor fails the gate with the exact
  expected-vs-observed mismatch.
- `Demo.bend` — runs it: for e = x²+3x at x=5, value is 40, derivative is 13
  computed both ways.

## Try it

Install Bend 2 (see https://bend-lang.com), then from this directory:

- `bend PROOF.bend` — the gate; prints `All terms check.` when every law holds
- `bend Demo.bend` — runs the demo: x²+3x at x=5, value 40, derivative 13 both ways

Break something in `Expr.bend` (e.g. the product rule in `diff`) and re-run
`bend PROOF.bend` — the gate fails with the exact expected-vs-observed mismatch.

## Workflow (Bend's "law-driven development")

1. State what must hold in `LAWS.bend` — the human writes it, the AI doesn't touch it.
2. Implement in `Expr.bend`, prove in `PROOF.bend` — the AI writes these.
3. `bend PROOF.bend` is the gate. Refactor freely; the gate catches breakage.

## Playground: d² = 0

`playground/d2-zero/` demonstrates the full **red → green → refactor** loop on the
smallest non-vacuous model of d² = 0 (the seed of Stokes' theorem): a single
triangle over Z/2. Red states the law with `?TODO` (gate fails honestly);
green proves it by 8-case brute force; refactor extracts the pure-algebra lemma
`xor_cancel3` from the geometry, guarded by the checker. Includes the
RED/GREEN/REFACTOR checker transcripts. Start here if you're new — it's the
first rung of the [learning path](https://github.com/lilalittle/bend-packages/issues/86).
Work-in-progress RGR demos live in `playground/` until they're ready to be
reorganized into real packages.

## Proof-style notes (Bend 2.0.27)

- The pair must be *literally* named `LAWS.bend` / `PROOF.bend`. `PROOF.bend`
  does `import ./LAWS.bend as Laws` and fills each law with a def named
  `def Laws.<lawname>(params):` — plain params only: no type annotations,
  no `+` annotations (both are parse errors there).
- Since law-filling defs can't take `+` params, delegate to a helper def with
  an explicit propositional return type when the proof needs a variable more
  than once (see `diff_correct_aux`).
- A `+` let-binding before a `match` is rejected; match directly on the
  parameter instead.
- `%e : P` rewrites right-to-left: given `e : {a == b}`, `P` is the current
  goal with `_` marking occurrences of `b`; the new goal is `P` with `a`
  filled in at each `_`.
- `{==}` closes a goal whose two sides compute to the same term.
  `?name` prints the current goal; `?TODO` leaves a proof open.
