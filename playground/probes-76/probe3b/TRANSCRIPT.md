# Probe 3b — Nat Failure-Phase Isolation: Experiment Transcript

All experiments 2026-10-01. Backends: `bend run` = program execution
(`bend <file>.bend`); `bend PROOF.bend` = proof checking (checker normalization).
Toolchains: 2.0.27 (`~/.bend/bin/bend`), 2.0.34 candidate
(`~/workspace/bend-staging/bend-2.0.34/bend/bin/bend`).

Pinned-source fact: Base's `Nat.add` is non-tail-recursive
(`match a: case 1n+p: 1n+Nat.add(p, b)`, base.bend:545). All `Nat.*`
arithmetic in Base is defined recursively; no primitive Nat ops in base.bend.

## (a) Large literal, no traversal — parse / elaboration / literal conversion

| # | Backend | Command | Input | Exit | Result | Phase |
|---|---------|---------|-------|------|--------|-------|
| A1 | 2.0.27 run | `bend a.bend` (`def main() -> Nat: 4294967295n`) | literal 2^32-1 | 0 | prints `4294967295n` | OK — literal conversion (U32.to_nat per guide) works |
| A2 | 2.0.34 run | same | literal 2^32-1 | 0 | prints `4294967295n` | OK |

Conclusion: literals are accepted, converted, and printed correctly. No unary
expansion of large literals. Parse/elaboration/conversion are NOT the failure.

## (b) Base arithmetic at runtime — compiled execution, no proof term

| # | Backend | Command | Input | Exit | Result | Phase |
|---|---------|---------|-------|------|--------|-------|
| B1 | 2.0.27 run | `bend b.bend` (`Nat.add(4294967295n, 1n)`) | 2^32-1 + 1 | 1 | `Error: the machine stack overflowed` | RUNTIME, non-tail recursion depth (~4.3B frames needed) |
| B2 | 2.0.34 run | same | 2^32-1 + 1 | 1 | stack overflow | RUNTIME, same |
| B3 | 2.0.27 run | `Nat.add(1000n, 1n)` | small | 0 | `1001n` | OK |
| B4 | 2.0.27 run | `Nat.add(2000n, 1n)` | small | 0 | `2001n` | OK |
| B5 | 2.0.27 run | `Nat.add(5000n, 1n)` | small | 0 | `5001n` | OK |
| B6 | 2.0.27 run | `Nat.add(10000n, 1n)` | 10k | 1 | stack overflow | RUNTIME — boundary between 5000 and 10000 frames |

Conclusion: runtime stack overflows on non-tail `Nat.add` between 5k–10k depth.
The value 10000n itself is representable (see A1, D1); the DEFINITION's
recursion pattern is the limit.

## (c) Output formatting, separately

Covered by A1/A2: the literal `4294967295n` was constructed via U32.to_nat
and printed exactly. Formatting of large Nats is NOT the failure.

## (d) Custom recursive operation — algorithmic recursion in isolation

| # | Backend | Command | Input | Exit | Result | Phase |
|---|---------|---------|-------|------|--------|-------|
| D1 | 2.0.27 run | `countdown(100000n)` (tail-recursive) | 100k depth | 0 | `0n` | OK — tail recursion to 100k works |
| D2 | 2.0.27 run | `countdown(10000n)` (tail-recursive) | 10k depth | 0 | `0n` | OK |

Conclusion: 100k-deep TAIL recursion works. The B-series failures are specific
to NON-TAIL recursion (pending `1n+` frames). "Nat ceiling ~10^4" is refuted
as a general claim: it is a non-tail-recursion depth ceiling.

## (e) Closed equality in the checker — checker computation vs execution

| # | Backend | Command | Input | Exit | Result | Phase |
|---|---------|---------|-------|------|--------|-------|
| E1 | 2.0.27 check | `bend PROOF.bend`, `{Nat.add(100n,1n)==101n}` via `{==}` | 100 steps | 0 | `All terms check.` | OK — checker normalizes |
| E2 | 2.0.27 check | `{Nat.add(1000n,1n)==1001n}` via `{==}` | 1k steps | 0 | `All terms check.` | OK |
| E3 | 2.0.27 check | `{Nat.add(10000n,1n)==10001n}` via `{==}` | 10k steps | 0 | `All terms check.` | OK — checker handles 10k where runtime (B6) overflows |
| E4 | 2.0.34 check | same as E3 | 10k steps | 0 | `ALL PROOFS CHECK` | OK |

Conclusion: the CHECKER normalizes 10k-step `Nat.add` fine. The B6 runtime
failure is NOT a checker/normalization limit. Checker and runtime have
different reduction limits; a proof that checks may still overflow at runtime
if executed via a non-tail-recursive definition.

## Mesh cells vs coefficient magnitude

| # | Backend | Command | Input | Exit | Result | Phase |
|---|---------|---------|-------|------|--------|-------|
| M1 | 2.0.27 run | `add_many(1000n, 0n)` — 1000 cells × 1n, tail-recursive loop, shallow adds | 1000 small coefs | 0 | `1000n` | OK |
| M2 | 2.0.34 run | same | 1000 small coefs | 0 | `1000n` | OK |
| M3 | 2.0.27 run | `Nat.add(1000000n, 1n)` — one huge coefficient | 1M coef | 1 | stack overflow | RUNTIME, non-tail depth |

Conclusion: 1000 mesh cells with small coefficients work fine on both
toolchains. Only a single huge coefficient overflows, via the non-tail
`Nat.add` recursion. Cell count and coefficient magnitude are independent
workloads; the failure tracks the latter through this definition.

## Permitted provisional conclusion (only)

> This particular Nat workload (`Nat.add` on a ~10k+ first argument) fails at
> this size through the runtime execution path; the compiled arithmetic and
> checker contracts must be measured separately.

NOT permitted: "execution is faithful only for small values" (a resource
failure is not evidence of an incorrect value — B3/B4/B5 returned correct
values, and D1 computed correctly at 100k depth). NOT permitted: "replace Nat
with U32" (no semantic bridge established; the public integer contract stays
exact).
