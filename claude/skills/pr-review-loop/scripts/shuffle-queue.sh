#!/usr/bin/env bash
# Shuffle stdin lines to stdout, preserving each line intact.
#
# Usage: discover-review-queue.sh | shuffle-queue.sh
#        printf '%s\n' 123 456 789 | shuffle-queue.sh
# Output: the same lines, in random order.
#
# Why a script instead of `shuf`: macOS does not ship `shuf` (it is GNU
# coreutils), and BSD `sort -R` hashes keys, so equal lines group together
# rather than scattering. The awk/sort/cut pipeline below works on a stock
# macOS and on Linux with no extra dependency.
#
# Why the explicit seed: awk's bare `srand()` seeds from the clock in whole
# seconds, so two sessions starting inside the same second would produce the
# *identical* shuffle — exactly the collision this script exists to prevent.
# Mixing in the PID makes concurrent sessions diverge even when they start
# simultaneously. Set PR_REVIEW_SHUFFLE_SEED to a fixed value to make the
# order reproducible (for testing).
set -uo pipefail

seed=${PR_REVIEW_SHUFFLE_SEED:-$(( ($$ * 7919 + $(date +%s)) % 2147483647 ))}

awk -v seed="$seed" '
  BEGIN { srand(seed) }
  { printf "%.17g\t%s\n", rand(), $0 }
' | sort -n | cut -f2-
