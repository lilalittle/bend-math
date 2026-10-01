#!/bin/bash
# tests/run_tests.sh -- regression harness for ../verify.sh.
#
# Reconstructs the seven fault-injection scenarios from the audit transcript
# using controlled `bend` test doubles, runs the repaired runner against each,
# and asserts the expected classification + runner exit code.
#
# Usage: ./tests/run_tests.sh   (run from playground/signed-chains/)

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYGROUND_DIR="$(dirname "$SCRIPT_DIR")"
PASS_COUNT=0
FAIL_COUNT=0

# ------------------------------------------------------------------ double --
# Writes a fake bend executable honoring the FAKE_* env vars at call time.
write_double() {
  local bindir="$1"
  cat >"$bindir/bend" <<'DOUBLE'
#!/bin/bash
case "$1" in
  version)
    printf '%s\n' "$FAKE_VERSION"
    ;;
  --help)
    printf 'Bend %s: check, run, build and publish Bend programs.\n' "$FAKE_VERSION"
    if [ "${FAKE_VERDICT_FLAG:-0}" = "1" ]; then
      printf '  bend <file.bend> --verdict    kernel check\n'
    fi
    ;;
  PROOF.bend)
    if [ $# -eq 1 ]; then
      printf '%b' "${FAKE_ORDINARY_STDOUT:-}"
      printf '%b' "${FAKE_ORDINARY_STDERR:-}" >&2
      exit "${FAKE_ORDINARY_EXIT:-0}"
    elif [ "$2" = "--verdict" ]; then
      printf '%b' "${FAKE_KERNEL_STDOUT:-}"
      printf '%b' "${FAKE_KERNEL_STDERR:-}" >&2
      exit "${FAKE_KERNEL_EXIT:-0}"
    fi
    ;;
esac
echo "fake bend: unexpected args: $*" >&2
exit 99
DOUBLE
  chmod +x "$bindir/bend"
}

# ------------------------------------------------------------------ runner --
# Sets up one scenario: fake toolchain in $T, scratch git repo with a copy of
# the playground dir, runs verify.sh with the double first on PATH.
# Env consumed: FAKE_VERSION, FAKE_BASE_MODE(real|fake), FAKE_VERDICT_FLAG,
#   FAKE_ORDINARY_STDOUT/STDERR/EXIT, FAKE_KERNEL_STDOUT/STDERR/EXIT.
# Outputs: T dir path on stdout.
setup_scenario() {
  local T
  T="$(mktemp -d "${TMPDIR:-/tmp}/runner-test.XXXXXXXX")"
  mkdir -p "$T/.bend/bin" "$T/.bend/bend2" "$T/repo/playground"
  write_double "$T/.bend/bin"
  if [ "${FAKE_BASE_MODE:-real}" = "real" ]; then
    cp "$HOME/.bend/bend2/base.bend" "$T/.bend/bend2/base.bend"
  else
    printf 'deliberately different Base contents\n' >"$T/.bend/bend2/base.bend"
  fi
  cp -r "$PLAYGROUND_DIR" "$T/repo/playground/signed-chains"
  git -C "$T/repo" init -q
  git -C "$T/repo" -c user.email=t@t -c user.name=t add -A
  git -C "$T/repo" -c user.email=t@t -c user.name=t commit -qm init
  printf '%s' "$T"
}

# Asserts one scenario. Args: name expected_exit expected_substrings...
# Reads scenario env from caller; prints one table row.
check() {
  local name="$1" expected_exit="$2"; shift 2
  local T out rc evdir ok=1
  T="$(setup_scenario)"
  out="$(PATH="$T/.bend/bin:$PATH" bash "$T/repo/playground/signed-chains/verify.sh" 2>&1)"
  rc=$?
  evdir="$(printf '%s' "$out" | sed -n 's/^evidence dir: //p' | head -n 1)"
  if [ "$rc" -ne "$expected_exit" ]; then ok=0; fi
  local s
  for s in "$@"; do
    if ! printf '%s' "$out" | grep -qF "$s"; then ok=0; fi
  done
  # raw evidence must exist and be unmodified (when the gate actually ran)
  if [ "${SKIP_EVIDENCE_CHECK:-0}" != "1" ] && [ -n "$evdir" ] && [ ! -f "$evdir/ordinary.stdout" ]; then ok=0; fi
  if [ $ok -eq 1 ]; then
    PASS_COUNT=$((PASS_COUNT + 1))
    printf 'PASS  %-28s exit=%d\n' "$name" "$rc"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf 'FAIL  %-28s exit=%d (expected %d)\n' "$name" "$rc" "$expected_exit"
    printf '%s\n' "$out" | head -n 20
  fi
  # expose evidence dir of the last scenario for extra assertions
  LAST_EVDIR="$evdir"
  LAST_OUT="$out"
  rm -rf "$T"
}

REAL_BASE_DIGEST="90a4a9a4ec3997d7d4927d7dac04f9ddd3b884e6521ac9d691bfe6765ba0d4d7"

echo "=== verify.sh regression tests (7 fault-injection scenarios) ==="

# 1. baseline success
FAKE_VERSION="bend 2.0.27" FAKE_BASE_MODE=real FAKE_VERDICT_FLAG=0 \
FAKE_ORDINARY_STDOUT='All terms check.\n' FAKE_ORDINARY_EXIT=0 \
  check baseline_success 0 \
    "ordinary: PASS (exit=0)" \
    "kernel (--verdict): UNSUPPORTED" \
    "RESULT: PASS"

# 2. failure message on stdout, checker exits 1 -> must be FAIL, nonzero exit
FAKE_VERSION="bend 2.0.27" FAKE_BASE_MODE=real FAKE_VERDICT_FLAG=0 \
FAKE_ORDINARY_STDOUT='injected checker failure on stdout\n' FAKE_ORDINARY_EXIT=1 \
  check ordinary_stdout_failure 1 \
    "ordinary: FAIL (exit=1)" \
    "injected checker failure on stdout"

# 3. failure message on stderr, checker exits 1 -> FAIL, diagnostic preserved
FAKE_VERSION="bend 2.0.27" FAKE_BASE_MODE=real FAKE_VERDICT_FLAG=0 \
FAKE_ORDINARY_STDOUT='' FAKE_ORDINARY_STDERR='injected checker failure on stderr\n' FAKE_ORDINARY_EXIT=1 \
  check ordinary_stderr_failure 1 \
    "ordinary: FAIL (exit=1)" \
    "injected checker failure on stderr"

# 4. success text with nonzero exit -> FAIL (exit status is required)
FAKE_VERSION="bend 2.0.27" FAKE_BASE_MODE=real FAKE_VERDICT_FLAG=0 \
FAKE_ORDINARY_STDOUT='All terms check.\n' FAKE_ORDINARY_EXIT=42 \
  check success_text_nonzero_exit 1 \
    "ordinary: FAIL (exit=42)"

# 5. open-obligation text with zero exit -> FAIL (no clean verdict)
FAKE_VERSION="bend 2.0.27" FAKE_BASE_MODE=real FAKE_VERDICT_FLAG=0 \
FAKE_ORDINARY_STDOUT='injected open proof obligation: ?TODO\n' FAKE_ORDINARY_EXIT=0 \
  check open_obligation_zero_exit 1 \
    "ordinary: FAIL (exit=0)"

# 6. kernel crash with 4 diagnostic lines, capability present ->
#    TOOL/RESOURCE FAILURE (never UNSUPPORTED), all lines preserved, nonzero exit
FAKE_VERSION="bend 2.0.27" FAKE_BASE_MODE=real FAKE_VERDICT_FLAG=1 \
FAKE_ORDINARY_STDOUT='All terms check.\n' FAKE_ORDINARY_EXIT=0 \
FAKE_KERNEL_STDOUT='injected kernel crash\ndetail line 2\ndetail line 3\ndetail line 4\n' FAKE_KERNEL_EXIT=139 \
  check kernel_crash 1 \
    "ordinary: PASS (exit=0)" \
    "kernel (--verdict): TOOL/RESOURCE FAILURE (exit=139)" \
    "detail line 4"
# extra assertion: all four raw lines present in the evidence artifact
if [ "$(wc -l <"$LAST_EVDIR/kernel.stdout")" -eq 4 ]; then
  PASS_COUNT=$((PASS_COUNT + 1)); printf 'PASS  %-28s %s\n' "kernel_evidence_4_lines" "raw artifact intact"
else
  FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL  %-28s %s\n' "kernel_evidence_4_lines" "expected 4 raw lines"
fi
if printf '%s' "$LAST_OUT" | grep -q "UNSUPPORTED"; then
  FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL  %-28s %s\n' "kernel_not_flattened" "crash was labeled UNSUPPORTED"
else
  PASS_COUNT=$((PASS_COUNT + 1)); printf 'PASS  %-28s %s\n' "kernel_not_flattened" "no UNSUPPORTED for crash"
fi

# 7. wrong toolchain (bend 9.9.9, different Base) -> explicit mismatch, nonzero exit
#    (gate never runs, so no ordinary evidence artifacts are expected)
SKIP_EVIDENCE_CHECK=1 \
FAKE_VERSION="bend 9.9.9" FAKE_BASE_MODE=fake FAKE_VERDICT_FLAG=0 \
FAKE_ORDINARY_STDOUT='All terms check.\n' FAKE_ORDINARY_EXIT=0 \
  check wrong_toolchain 2 \
    "TOOLCHAIN MISMATCH"
unset SKIP_EVIDENCE_CHECK

echo
echo "passed: $PASS_COUNT  failed: $FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
