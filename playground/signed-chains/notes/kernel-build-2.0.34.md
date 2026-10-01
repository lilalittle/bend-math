# Isolated Lean v4.34.0 kernel build for Bend 2.0.34 --verdict

Date: 2026-10-01. Candidate: Bend 2.0.34 staged at
`~/workspace/bend-staging/bend-2.0.34/` (binary
`~/workspace/bend-staging/bend-2.0.34/bend/bin/bend`).
Pinned 2.0.27 at `~/.bend` was not modified; all work in /tmp and the
candidate tree. No system-wide installs (elan went to `~/.elan`).

## The three facts, kept separate

### 1. Capability: SUPPORTED
`bend --help` (2.0.34) documents:
`bend <file.bend> --verdict   check it, then recheck it with the proven kernel`.
The flag exists and dispatches. (Baseline before provisioning, from the
staging log: `Error: the kernel did not build (lean: Executable not found
in $PATH: "lean"); --verdict needs Lean v4.34.0 (elan toolchain
leanprover/lean4:v4.34.0), or $BENDTT set to a built kernel`.)

### 2. Environment readiness: READY (provisioned in this session)
- Installed elan 4.2.4 via the official installer
  (`curl https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none`).
- `elan toolchain install leanprover/lean4:v4.34.0` → Lean 4.34.0,
  x86_64-unknown-linux-gnu, commit 293d5d0c0c3f3dded4688b3ccd6a33939ac5102b.
- First `bend PROOF.bend --verdict` built the kernel automatically
  (bend compiles `bend2/bendtt.lean` with `lean` → C → native exe; took ~72s).
  Built kernel cached by bend at `~/.bend/bendtt/61e0d2d9f4ddd7dd/`:
  `bendtt` (ELF 64-bit, 5.4 MB), `bendtt.c`, `bendtt.lean`.
  (Cache location is bend's own default; the 2.0.27 pin files were untouched.)
- Subsequent --verdict runs reuse the cached kernel (<1s).
- `$BENDTT` was never set; not needed once `lean` is in PATH.

### 3. Corpus result: ESTABLISHED BY ACTUAL RUN
`~/workspace/bend-math/playground/signed-chains/PROOF.bend`
(2.0.34 binary):
- ordinary: `ALL PROOFS CHECK` (+ `Use --verdict for mathematical validity.`), exit 0
- `--verdict`: `ALL PROOFS CHECK`, exit 0, 0.49s (kernel cached)
- No fuel/timeout issue on this corpus. The release-notes fuel warning
  concerns a particular large shared-graph proof, not these small
  signed-chain proofs.

## Controls (kernel discrimination)

Valid control (`/tmp/kernel-probe/mini`: law `{1n == 1n : Nat}` proven by `{==}`):
- ordinary: `ALL PROOFS CHECK`, exit 0
- `--verdict`: `ALL PROOFS CHECK`, exit 0

Invalid control 1 (proof relying on `@unsafe def`):
- ordinary: `SOME PROOFS FAIL` / `1 def relies on unsafe or foreign code: helper`, exit 1
- `--verdict`: identical `SOME PROOFS FAIL`, exit 1
- (2.0.34's ordinary checker already refuses unsafe code, so this does not
  isolate the kernel.)

Invalid control 2 — direct kernel binary, corrupted translation (strongest):
- `bend PROOF.bend -o PROOF.bendtt`, then ran the built kernel directly:
  `~/.bend/bendtt/61e0d2d9f4ddd7dd/bendtt PROOF.bendtt`
  → `ALL PROOFS CHECK`, exit 0
- Corrupted copy claiming `Succ == Zero` with `{==}` as proof:
  → `SOME PROOFS FAIL` / `In LAWS.trivial: expected: (.Succ, ...) observed: (.Zero, ())`, exit 1
- The kernel independently rechecks; it is not parroting bend2.

## Exact commands (reproducible)

```bash
export PATH="$HOME/.elan/bin:$PATH"
elan toolchain install leanprover/lean4:v4.34.0
B=~/workspace/bend-staging/bend-2.0.34/bend/bin/bend
cd ~/workspace/bend-math/playground/signed-chains
$B PROOF.bend --verdict        # ALL PROOFS CHECK, exit 0
```

## Notes / caveats
- This establishes a kernel result for the current signed-chains corpus on
  2.0.34 only. It is NOT retroactive acceptance of anything on 2.0.27, and it
  does not evaluate the kernel's own Lean proof — only that the built kernel
  accepts the corpus and rejects corrupted input.
- No in-scope kernel rejection occurred (nothing to investigate); no timeout
  occurred. No promotion veto or pass follows from this alone — that decision
  stays with the pin-change review.
