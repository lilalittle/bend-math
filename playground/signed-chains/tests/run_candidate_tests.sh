#!/bin/bash
# tests/run_candidate_tests.sh -- candidate-profile (2.0.34) fixtures.
#
# Runs verify.sh with BEND_PROFILE=candidate against the STAGED 2.0.34
# binary (never ~/.bend; BEND_NO_TELEMETRY=1). Four fixtures:
#   positive        proof checks                    -> ordinary: PASS
#   open_obligation ?TODO filler                    -> ordinary: FAIL
#   rejection       deliberately false proof        -> ordinary: FAIL
#   tool_failure    crashed kernel invocation       -> kernel: TOOL/RESOURCE FAILURE (never UNSUPPORTED)
#
# Assertions read the ACTUAL final classifications from the run summary
# (ordinary: / kernel: lines), not substring presence in raw output.
# The mark: the candidate profile classifies positive and negative
# fixtures correctly, with its own versioned reporting contract
# (ALL PROOFS CHECK / SOME PROOFS FAIL), independent of the pinned 2.0.27
# profile. The default pin is untouched by this script.
#
# Usage: ./tests/run_candidate_tests.sh   (run from playground/signed-chains/)

set -u
export BEND_NO_TELEMETRY=1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYGROUND_DIR="$(dirname "$SCRIPT_DIR")"
STAGED="$HOME/workspace/bend-staging/bend-2.0.34/bend"
PASS_COUNT=0
FAIL_COUNT=0

# ------------------------------------------------------- pre-flight ----
# The staged binary must match the manifest identity the candidate profile
# declares; otherwise the fixtures would test an unknown toolchain.
MANIFEST_BIN_SHA="7fafb749dd33df446a0cb5839c5694df237312a8e8048d2e9420480164ff5934"
ACTUAL_BIN_SHA="$(sha256sum "$STAGED/bin/bend" | cut -d' ' -f1)"
if [ "$ACTUAL_BIN_SHA" != "$MANIFEST_BIN_SHA" ]; then
  echo "PRE-FLIGHT FAILURE: staged binary digest mismatch" >&2
  echo "  expected: $MANIFEST_BIN_SHA" >&2
  echo "  actual:   $ACTUAL_BIN_SHA" >&2
  exit 2
fi
echo "pre-flight: staged 2.0.34 binary matches manifest ($ACTUAL_BIN_SHA)"
echo

# ------------------------------------------------------- scenario -----
# Sets up a scratch repo with a copy of the playground; $1 selects the
# PROOF.bend variant (real|todo|reject). Prints the scratch dir.
setup_scenario() {
  local variant="$1" T
  T="$(mktemp -d "${TMPDIR:-/tmp}/candidate-test.XXXXXXXX")"
  mkdir -p "$T/repo/playground"
  cp -r "$PLAYGROUND_DIR" "$T/repo/playground/signed-chains"
  case "$variant" in
    todo)
      python3 - "$T/repo/playground/signed-chains/PROOF.bend" <<'EOF'
import sys
p = sys.argv[1]
t = open(p).read()
t = t.replace("def Laws.boundary_squared_zero():\n  {==}",
              "def Laws.boundary_squared_zero():\n  ?TODO", 1)
open(p, 'w').write(t)
EOF
      ;;
    reject)
      python3 - "$T/repo/playground/signed-chains/PROOF.bend" <<'EOF'
import sys
p = sys.argv[1]
t = open(p).read()
t = t.replace("def Laws.boundary_squared_zero():\n  {==}",
              "def Laws.boundary_squared_zero():\n  {Laws.vchain_is_zero(Laws.b1(Laws.b2)) == False{} : Bool}", 1)
open(p, 'w').write(t)
EOF
      ;;
  esac
  git -C "$T/repo" init -q
  git -C "$T/repo" -c user.email=t@t -c user.name=t add -A
  git -C "$T/repo" -c user.email=t@t -c user.name=t commit -qm init
  printf '%s' "$T"
}

# Crashing-compiler double for the tool-failure fixture: reports the
# candidate version, advertises --verdict, passes the ordinary gate, then
# crashes on the kernel invocation. Uses the REAL staged base.bend so the
# profile's Base-digest enforcement is exercised, not bypassed.
write_crashing_double() {
  local T="$1"
  mkdir -p "$T/toolchain/bin" "$T/toolchain/bend2"
  cp "$STAGED/bend2/base.bend" "$T/toolchain/bend2/base.bend"
  cat >"$T/toolchain/bin/bend" <<'DOUBLE'
#!/bin/bash
case "$1" in
  version)
    printf 'bend 2.0.34\n'
    ;;
  --help)
    printf 'Bend 2.0.34: check, run, build and publish Bend programs.\n'
    printf '  bend <file.bend> --verdict    kernel check\n'
    exit 0
    ;;
  PROOF.bend)
    if [ $# -eq 1 ]; then
      printf 'ALL PROOFS CHECK\n'
      exit 0
    elif [ "$2" = "--verdict" ]; then
      printf 'injected kernel crash\n' >&2
      exit 139
    fi
    ;;
esac
echo "fake bend: unexpected args: $*" >&2
exit 99
DOUBLE
  chmod +x "$T/toolchain/bin/bend"
}

# Runs verify.sh under the candidate profile. $1 = scratch dir,
# $2 = PATH prefix for the bend binary. Sets LAST_* globals.
run_candidate() {
  local T="$1" pathbin="$2" out rc
  out="$(BEND_PROFILE=candidate PATH="$pathbin:$PATH" bash "$T/repo/playground/signed-chains/verify.sh" 2>&1)"
  rc=$?
  LAST_OUT="$out"
  LAST_RC="$rc"
  LAST_EVDIR="$(printf '%s' "$out" | sed -n 's/^evidence dir: //p' | head -n 1)"
  LAST_SUMMARY="$LAST_EVDIR/summary.txt"
}

# Asserts the actual summary classifications. Args:
#   name expected_rc expected_ordinary expected_kernel_prefix
check() {
  local name="$1" expected_rc="$2" expected_ordinary="$3" expected_kernel="$4"
  local ok=1 ord kern_full
  ord="$(sed -n 's/^ordinary    : \([A-Z]*\).*/\1/p' "$LAST_SUMMARY")"
  kern_full="$(sed -n 's/^kernel      : //p' "$LAST_SUMMARY")"
  [ "$LAST_RC" -eq "$expected_rc" ] || ok=0
  [ "$ord" = "$expected_ordinary" ] || ok=0
  case "$kern_full" in "$expected_kernel"*) ;; *) ok=0 ;; esac
  if [ $ok -eq 1 ]; then
    PASS_COUNT=$((PASS_COUNT + 1))
    printf 'PASS  %-24s rc=%d ordinary=%s kernel=[%s]\n' "$name" "$LAST_RC" "$ord" "$kern_full"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf 'FAIL  %-24s rc=%d (want %d) ordinary=%s (want %s) kernel=[%s] (want %s*)\n' \
      "$name" "$LAST_RC" "$expected_rc" "$ord" "$expected_ordinary" "$kern_full" "$expected_kernel"
  fi
  # record the actual classifications for the final table
  printf '%-24s | ordinary=%-4s | kernel=%s\n' "$name" "$ord" "$(sed -n 's/^kernel      : //p' "$LAST_SUMMARY")" >>"$RESULT_TABLE"
}

RESULT_TABLE="$(mktemp)"
echo "=== candidate profile (2.0.34) fixtures ==="
echo "profile contract: clean='ALL PROOFS CHECK', failure includes 'SOME PROOFS FAIL'"
echo

# 1. positive: the real corpus checks under the candidate toolchain.
# The ordinary gate must be PASS. The kernel gate is environment-dependent
# (needs Lean v4.34.0/BendTT): it must be an honest classification -- PASS
# when the kernel runs, TOOL/RESOURCE FAILURE on the environment gap --
# and NEVER a flattened capability verdict. The runner exit follows the
# honest aggregate (0 iff both gates pass).
T="$(setup_scenario real)"
run_candidate "$T" "$STAGED/bin"
{
  ord="$(sed -n 's/^ordinary    : \([A-Z]*\).*/\1/p' "$LAST_SUMMARY")"
  kern_full="$(sed -n 's/^kernel      : //p' "$LAST_SUMMARY")"
  ok=1
  [ "$ord" = "PASS" ] || ok=0
  case "$kern_full" in
    "PASS (exit=0)"*)               expected_rc=0 ;;
    "TOOL/RESOURCE FAILURE"*)       expected_rc=1 ;;
    *) ok=0; expected_rc="?" ;;
  esac
  case "$kern_full" in
    *"UNSUPPORTED"*) ok=0 ;;
  esac
  [ "$LAST_RC" -eq "$expected_rc" ] || ok=0
  if [ $ok -eq 1 ]; then
    PASS_COUNT=$((PASS_COUNT + 1))
    printf 'PASS  %-24s rc=%d ordinary=%s kernel=[%s]\n' "positive" "$LAST_RC" "$ord" "$kern_full"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf 'FAIL  %-24s rc=%d ordinary=%s kernel=[%s]\n' "positive" "$LAST_RC" "$ord" "$kern_full"
  fi
  printf '%-24s | ordinary=%-4s | kernel=%s\n' "positive" "$ord" "$kern_full" >>"$RESULT_TABLE"
}
rm -rf "$T"

# 2. open obligation: ?TODO must be FAIL, never PASS.
T="$(setup_scenario todo)"
run_candidate "$T" "$STAGED/bin"
check "open_obligation" 1 "FAIL" ""
rm -rf "$T"

# 3. rejection: a deliberately false proof must be FAIL, never PASS.
T="$(setup_scenario reject)"
run_candidate "$T" "$STAGED/bin"
check "rejection" 1 "FAIL" ""
rm -rf "$T"

# 4. tool failure: crashed kernel invocation is TOOL/RESOURCE FAILURE,
#    never UNSUPPORTED, runner exits nonzero.
T="$(setup_scenario real)"
write_crashing_double "$T"
run_candidate "$T" "$T/toolchain/bin"
check "tool_failure" 1 "PASS" "TOOL/RESOURCE FAILURE"
if grep -q "^kernel      : UNSUPPORTED" "$LAST_SUMMARY"; then
  FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL  %-24s %s\n' "crash_not_unsupported" "crash flattened to UNSUPPORTED"
else
  PASS_COUNT=$((PASS_COUNT + 1)); printf 'PASS  %-24s %s\n' "crash_not_unsupported" "crash kept as TOOL/RESOURCE FAILURE"
fi
rm -rf "$T"

echo
echo "--- actual final classifications ---"
cat "$RESULT_TABLE"
rm -f "$RESULT_TABLE"
echo
echo "passed: $PASS_COUNT  failed: $FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
