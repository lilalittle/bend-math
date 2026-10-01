#!/bin/bash
# verify.sh -- the one reproducible command for playground/signed-chains.
#
# Prints pinned toolchain identifiers, ENFORCES them (exact version and Base
# digest match, nonzero exit on mismatch), runs the ordinary Bend proof gate,
# then determines kernel-check capability SEPARATELY from execution.
#
# Gate contract (ordinary):
#   PASS requires BOTH: checker exit status 0 AND the pinned version's
#   recognized clean verdict ("All terms check.") present in stdout, with no
#   failure markers on EITHER stream. Success-shaped output with nonzero exit,
#   open-obligation (?TODO) text, and discarded diagnostics can never become PASS.
#   Any failed required gate yields a NONZERO runner exit.
#
# Kernel check (--verdict):
#   Capability is established from version/capability evidence (pinned
#   2.0.27's --help has no --verdict flag) or a specifically recognized
#   unknown-option diagnostic -- never from a failed execution. A --help
#   invocation that itself fails is a tool/resource failure, not capability
#   evidence, and must never fall through into the UNSUPPORTED branch.
#   Crashes, timeouts, and proof failures keep their own classifications
#   (tool/resource failure) and fail closed with a nonzero runner exit.
#   UNSUPPORTED is recorded only for genuinely missing capability.
#
# Evidence:
#   Every run stores RAW, UNMODIFIED stdout, stderr, and exit code per
#   invocation in a per-run directory (mktemp -d). Display text may be
#   shortened; it never replaces the raw artifacts. Artifact paths are
#   printed so a reviewer can inspect them.
#
# Reproducibility:
#   Repository identity is resolved relative to this script's own directory,
#   never a hard-coded path. The checked snapshot is recorded as full
#   revision + dirty state + blob identities of the checked files.
#
# Trust boundary (what the gate is and is not):
#  - The ordinary gate typechecks PROOF.bend and its full import closure
#    (LAWS.bend, Algebra.bend, Base), verifying every def with a
#    propositional return type, including all law fillers.
#  - Base ships its own definitions and unproved laws; we reuse its
#    computation rules but prove our own lemmas.
#  - The gate checks that the FORMALIZATION is correct; whether the
#    formalization captures the intended mathematics (spec correctness)
#    is argued in the README and notes, not established by the gate.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ---------------------------------------------------------------- pins ----
PINNED_BEND_VERSION="bend 2.0.27"
PINNED_BASE_SHA256="90a4a9a4ec3997d7d4927d7dac04f9ddd3b884e6521ac9d691bfe6765ba0d4d7"
CLEAN_VERDICT="All terms check."
# Failure markers the pinned checker emits; their presence voids any PASS.
FAILURE_MARKERS="TODO|Error|error:|incomplete|not a valid|FAIL"

RUNNER_EXIT=0
note_failure() { RUNNER_EXIT=1; }

# ------------------------------------------------- evidence directory ----
EVIDENCE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/signed-chains-verify.XXXXXXXX")"
echo "evidence dir: $EVIDENCE_DIR"

# ------------------------------------------------- toolchain enforcement --
BEND_BIN="$(command -v bend || true)"
if [ -z "$BEND_BIN" ]; then
  echo "TOOLCHAIN MISMATCH: bend not found on PATH" >&2
  exit 2
fi
# Canonicalize so the Base lookup below fingerprints the bytes THIS binary uses.
BEND_BIN="$(cd "$(dirname "$BEND_BIN")" && pwd)/$(basename "$BEND_BIN")"

BEND_VERSION_LINE="$("$BEND_BIN" version 2>/dev/null | head -n 1)"
if [ "$BEND_VERSION_LINE" != "$PINNED_BEND_VERSION" ]; then
  echo "TOOLCHAIN MISMATCH: expected bend version '$PINNED_BEND_VERSION', got '$BEND_VERSION_LINE'" >&2
  echo "  (binary: $BEND_BIN)" >&2
  exit 2
fi

BEND_HOME="$(dirname "$(dirname "$BEND_BIN")")"
BASE_BEND="$BEND_HOME/bend2/base.bend"
if [ ! -f "$BASE_BEND" ]; then
  echo "TOOLCHAIN MISMATCH: base.bend not found at $BASE_BEND (resolved relative to $BEND_BIN)" >&2
  exit 2
fi
BASE_DIGEST="$(sha256sum "$BASE_BEND" | cut -d' ' -f1)"
if [ "$BASE_DIGEST" != "$PINNED_BASE_SHA256" ]; then
  echo "TOOLCHAIN MISMATCH: base.bend digest mismatch" >&2
  echo "  expected: $PINNED_BASE_SHA256" >&2
  echo "  actual:   $BASE_DIGEST ($BASE_BEND)" >&2
  exit 2
fi

echo "=== pinned toolchain (enforced) ==="
echo "bend version: $BEND_VERSION_LINE"
echo "bend binary : $BEND_BIN"
echo "base.bend   : $BASE_DIGEST  ($BASE_BEND)"

# ------------------------------------------------- snapshot identity ------
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  echo "REPRODUCIBILITY FAILURE: script is not inside a git checkout ($SCRIPT_DIR)" >&2
  exit 2
fi
SNAP_REV="$(git -C "$REPO_ROOT" rev-parse HEAD)"
SNAP_DIRTY="$(git -C "$REPO_ROOT" status --porcelain || true)"
REL_DIR="${SCRIPT_DIR#$REPO_ROOT/}"
SNAP_BLOBS="$(git -C "$REPO_ROOT" ls-files -s -- "$REL_DIR" | awk '{print $2" "$4}')"
echo "repo root   : $REPO_ROOT"
echo "revision    : $SNAP_REV"
if [ -n "$SNAP_DIRTY" ]; then
  echo "dirty state : DIRTY (uncommitted changes present)"
else
  echo "dirty state : clean"
fi
echo

# ------------------------------------------------- gate execution ---------
# Capture raw stdout, raw stderr, and exit code separately, before any
# filtering or reporting. Never pipe through grep for classification.
run_gate() {
  local name="$1"; shift
  "$@" >"$EVIDENCE_DIR/$name.stdout" 2>"$EVIDENCE_DIR/$name.stderr"
  echo "$?" >"$EVIDENCE_DIR/$name.exit"
}

echo "=== ordinary gate: bend PROOF.bend ==="
run_gate ordinary "$BEND_BIN" PROOF.bend
ORD_EXIT="$(cat "$EVIDENCE_DIR/ordinary.exit")"
ORDINARY_RESULT="FAIL"
if [ "$ORD_EXIT" -eq 0 ] \
  && grep -qF "$CLEAN_VERDICT" "$EVIDENCE_DIR/ordinary.stdout" \
  && ! grep -qE "$FAILURE_MARKERS" "$EVIDENCE_DIR/ordinary.stdout" "$EVIDENCE_DIR/ordinary.stderr"; then
  ORDINARY_RESULT="PASS"
else
  note_failure
fi
echo "ordinary: $ORDINARY_RESULT (exit=$ORD_EXIT)"
echo "--- ordinary stdout (raw) ---"
cat "$EVIDENCE_DIR/ordinary.stdout"
echo "--- ordinary stderr (raw) ---"
cat "$EVIDENCE_DIR/ordinary.stderr"
echo

# ------------------------------------------------- kernel capability -----
# Determine capability from version/capability evidence, NOT from a failed run.
echo "=== kernel check: bend PROOF.bend --verdict ==="
KERNEL_RESULT=""
run_gate help "$BEND_BIN" --help
HELP_EXIT="$(cat "$EVIDENCE_DIR/help.exit")"
if [ "$HELP_EXIT" -ne 0 ]; then
  # A failing --help is a tool/resource failure, not capability evidence:
  # it must never fall through into the UNSUPPORTED branch.
  KERNEL_RESULT="TOOL/RESOURCE FAILURE (bend --help failed, exit=$HELP_EXIT; capability undetermined)"
  note_failure
  echo "kernel (--verdict): $KERNEL_RESULT"
elif grep -q -- "--verdict" "$EVIDENCE_DIR/help.stdout"; then
  KERNEL_SUPPORTED=1
else
  KERNEL_SUPPORTED=0
fi

if [ -n "$KERNEL_RESULT" ]; then
  # Capability discovery already failed. Preserve that terminal result;
  # do not attempt a kernel invocation or overwrite its classification.
  :
elif [ "$KERNEL_SUPPORTED" -eq 0 ]; then
  KERNEL_RESULT="UNSUPPORTED (pinned $PINNED_BEND_VERSION has no --verdict flag; established from --help, not from execution)"
  echo "kernel (--verdict): $KERNEL_RESULT"
else
  run_gate kernel "$BEND_BIN" PROOF.bend --verdict
  K_EXIT="$(cat "$EVIDENCE_DIR/kernel.exit")"
  K_STDERR="$(cat "$EVIDENCE_DIR/kernel.stderr")"
  if echo "$K_STDERR" | grep -qi "unknown option.*verdict"; then
    # Specifically recognized unknown-option diagnostic: capability absent.
    KERNEL_RESULT="UNSUPPORTED (unknown-option diagnostic)"
    echo "kernel (--verdict): $KERNEL_RESULT"
  elif [ "$K_EXIT" -eq 0 ] \
    && grep -qF "$CLEAN_VERDICT" "$EVIDENCE_DIR/kernel.stdout" \
    && ! grep -qE "$FAILURE_MARKERS" "$EVIDENCE_DIR/kernel.stdout" "$EVIDENCE_DIR/kernel.stderr"; then
    KERNEL_RESULT="PASS (exit=0)"
    echo "kernel (--verdict): $KERNEL_RESULT"
  else
    # Fail closed: a crash, timeout, or proof failure is a tool/resource
    # failure -- it must never be flattened into UNSUPPORTED.
    KERNEL_RESULT="TOOL/RESOURCE FAILURE (exit=$K_EXIT)"
    note_failure
    echo "kernel (--verdict): $KERNEL_RESULT"
  fi
  echo "--- kernel stdout (raw) ---"
  cat "$EVIDENCE_DIR/kernel.stdout"
  echo "--- kernel stderr (raw) ---"
  cat "$EVIDENCE_DIR/kernel.stderr"
fi
echo

# ------------------------------------------------- summary ----------------
{
  echo "=== verify.sh run summary ==="
  echo "bend version: $BEND_VERSION_LINE"
  echo "bend binary : $BEND_BIN"
  echo "base.bend   : $BASE_DIGEST  ($BASE_BEND)"
  echo "revision    : $SNAP_REV"
  if [ -n "$SNAP_DIRTY" ]; then echo "dirty state : DIRTY"; else echo "dirty state : clean"; fi
  echo "checked blobs (git blob-id path):"
  echo "$SNAP_BLOBS" | sed 's/^/  /'
  echo "ordinary    : $ORDINARY_RESULT (exit=$ORD_EXIT)"
  echo "kernel      : $KERNEL_RESULT"
  echo "evidence dir: $EVIDENCE_DIR"
  echo "runner exit : $RUNNER_EXIT"
} | tee "$EVIDENCE_DIR/summary.txt"

# Regenerate the committed human-readable record from THIS run's evidence,
# so it always describes the actually-checked snapshot.
cp "$EVIDENCE_DIR/summary.txt" "$SCRIPT_DIR/VERIFY.txt"

if [ "$RUNNER_EXIT" -ne 0 ]; then
  echo "RESULT: FAIL (see evidence dir above)" >&2
else
  echo "RESULT: PASS"
fi
exit "$RUNNER_EXIT"
