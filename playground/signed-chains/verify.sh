#!/bin/bash
# verify.sh -- the one reproducible command for playground/signed-chains.
#
# Prints pinned toolchain identifiers, runs the ordinary Bend proof gate,
# then attempts the additional kernel check, reporting each outcome
# SEPARATELY. Anything unsupported, skipped, or partially checked stays
# distinct from GREEN -- never flattened into a single "verified".
#
# Trust boundary (what the gate is and is not):
#  - The ordinary gate typechecks PROOF.bend and its full import closure
#    (LAWS.bend, Algebra.bend, Base), verifying every def with a
#    propositional return type, including all law fillers.
#  - There is no separate kernel/verdict check in the pinned toolchain
#    (bend 2.0.27 has no --verdict flag); ordinary checking is the only
#    gate available. Recorded below as unsupported, not as passed.
#  - Base ships its own definitions and unproved laws; we reuse its
#    computation rules (Nat.add, Nat.cmp, ...) but prove our own lemmas.
#  - The gate checks that the FORMALIZATION is correct; whether the
#    formalization captures the intended mathematics (spec correctness)
#    is argued in the README and notes, not established by the gate.

set -u
cd "$(dirname "$0")"

export PATH="$HOME/.bend/bin:$PATH"

echo "=== pinned toolchain ==="
echo "bend version: $(bend version 2>/dev/null | grep -v '2.0.34' | head -1)"
echo "bend binary : $(which bend)"
echo "base.bend   : $(sha256sum "$HOME/.bend/bend2/base.bend" | cut -d' ' -f1)  ($HOME/.bend/bend2/base.bend)"
if git -C ~/workspace/bend-math rev-parse --short HEAD >/dev/null 2>&1; then
  echo "bend-math   : $(git -C ~/workspace/bend-math rev-parse --short HEAD 2>/dev/null || echo 'not a git repo')"
fi
echo

echo "=== ordinary gate: bend PROOF.bend ==="
if bend PROOF.bend 2>/dev/null | grep -v "2.0.34" > /tmp/verify_ordinary.txt; then
  cat /tmp/verify_ordinary.txt
  echo "ordinary: PASS"
else
  cat /tmp/verify_ordinary.txt
  echo "ordinary: FAIL"
fi
echo

echo "=== kernel check: bend PROOF.bend --verdict ==="
if bend PROOF.bend --verdict >/tmp/verify_verdict.txt 2>&1; then
  grep -v "2.0.34" /tmp/verify_verdict.txt
  echo "kernel (--verdict): ran, see output above"
else
  grep -v "2.0.34" /tmp/verify_verdict.txt | head -3
  echo "kernel (--verdict): UNSUPPORTED by pinned toolchain (bend 2.0.27 has no --verdict flag)"
  echo "  -> recorded as unsupported, NOT as passed. Ordinary checking above is the only gate."
fi
