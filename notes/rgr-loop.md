# The RGR loop

**Red → green → refactor**, applied to proofs instead of programs. Each phase
is guarded by `bend PROOF.bend`.

**🔴 Red.** Write the law first, with `?TODO` as the proof. The gate fails —
`Error: N TODO found` — and the failure is honest: here is the frontier of
what you know. State the theorem *before* you understand it. This is the
open-conjecture convention: the unknown, made explicit and machine-readable.

**🟢 Green.** Prove it by any means that holds: brute-force case analysis, ugly
manual equational rewriting, `{==}` wherever both sides compute. `All terms
check.` You cannot green a proof you don't understand — **the proof attempt is
the studying**. Whatever the math was hiding, the green phase drags it into
the light.

**🔵 Refactor.** Restructure under the checker's guard: extract lemmas,
generalize, separate geometry from algebra. If the restructuring breaks the
connection, the gate rejects it. Every extracted reusable lemma is a candidate
publishable package — this is where the ecosystem grows as exhaust.

**Worked example:** [`playground/d2-zero/`](../playground/d2-zero/) runs the
full cycle on d² = 0 over a triangle: red (failing law), green (8-case proof),
refactor (`xor_cancel3` extracted from `d2_zero`). The RED/GREEN/REFACTOR
transcripts are in the folder.

## See also

- [d² = 0](d2-zero.md) — the theorem the worked example proves
- [Learning path](learning-path.md) — the curriculum this loop climbs
