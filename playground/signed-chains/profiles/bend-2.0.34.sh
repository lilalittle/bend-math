# profiles/bend-2.0.34.sh -- explicitly selected CANDIDATE profile.
#
# Selected ONLY via BEND_PROFILE=candidate (or BEND_PROFILE=2.0.34).
# It never becomes the default; the pin stays 2.0.27 until an explicit
# pin-change review. This profile lets the runner verify a candidate
# toolchain with its own versioned reporting contract, instead of
# queuing candidate support behind the pin decision.
#
# Compiler identity (from ~/workspace/bend-staging/STAGING-LOG-2.0.34.md;
# staged at ~/workspace/bend-staging/bend-2.0.34/bend/, never re-downloaded).

PROFILE_NAME="candidate"
PROFILE_BEND_VERSION="bend 2.0.34"
PROFILE_BASE_SHA256="c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661"

# Declared (not runner-enforced) binary identity, for reviewer cross-check
# against the staging manifest. The runner enforces version string + Base
# digest, which are what determine checking semantics.
PROFILE_BINARY_SHA256="7fafb749dd33df446a0cb5839c5694df237312a8e8048d2e9420480164ff5934"
PROFILE_TARBALL_SHA256="78106a97af242429dcc057258eb8d10f69cddebcd5e263022185a52d003e09bf"

# Versioned reporting contract (2.0.32+): ordinary proof checking
# distinguishes ALL PROOFS CHECK from SOME PROOFS FAIL, with additional
# conditions concerning unsafe and foreign dependencies. This is a
# per-version contract -- the runner must NOT globally replace the old
# string, nor accept either string under every version. Each profile
# declares its own clean-verdict string and failure markers.
PROFILE_CLEAN_VERDICT="ALL PROOFS CHECK"
PROFILE_FAILURE_MARKERS="TODO|Error|error:|incomplete|not a valid|FAIL|SOME PROOFS FAIL"

# Kernel capability expectation: --verdict EXISTS in 2.0.34 (--help lists
# it), so capability discovery succeeds and the runner WILL invoke the
# kernel. Kernel execution needs Lean v4.34.0 / BendTT in the environment:
# with it present, the kernel genuinely rechecks the proofs (verified:
# PASS on the signed-chains corpus, REJECT on a false proof, 2026-10-01);
# without it, the honest classification is TOOL/RESOURCE FAILURE
# (environment gap) -- never a flattened capability verdict, and never
# a proof verdict.
PROFILE_KERNEL_EXPECTATION="--verdict flag present; kernel runs when Lean v4.34.0/BendTT is in the environment, else TOOL/RESOURCE FAILURE (environment gap)"
