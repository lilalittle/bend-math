# profiles/bend-2.0.27.sh -- pinned default profile.
#
# This is the DEFAULT profile (BEND_PROFILE unset, "pinned", or "2.0.27").
# It declares the pinned toolchain's identity and its VERSIONED reporting
# contract. Nothing here changes the pin; the candidate profile lives in
# bend-2.0.34.sh and is only used when explicitly selected.

PROFILE_NAME="pinned"
PROFILE_BEND_VERSION="bend 2.0.27"
PROFILE_BASE_SHA256="90a4a9a4ec3997d7d4927d7dac04f9ddd3b884e6521ac9d691bfe6765ba0d4d7"

# Versioned reporting contract for 2.0.27's ordinary gate: success is the
# literal string "All terms check." on stdout with exit 0 and no failure
# markers on either stream.
PROFILE_CLEAN_VERDICT="All terms check."
PROFILE_FAILURE_MARKERS="TODO|Error|error:|incomplete|not a valid|FAIL"

# Kernel capability expectation for this toolchain: 2.0.27 has no --verdict
# flag, so the runner must record the capability as absent from --help
# evidence -- never from a failed execution, and never after a failed
# capability probe. (Worded to avoid the classification string itself,
# which the regression harness reserves for actual classifications.)
PROFILE_KERNEL_EXPECTATION="--verdict flag absent in 2.0.27; absence established from --help evidence, never from execution"
