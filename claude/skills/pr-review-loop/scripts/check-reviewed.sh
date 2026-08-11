#!/usr/bin/env bash
# Ask whether a PR has already been reviewed at a specific head commit, by any
# pr-review-loop session. Pairs with mark-reviewed.sh.
#
# Usage: check-reviewed.sh <owner> <repo> <number> --sha <head_sha>
# Output: one JSON object (always exit 0 unless usage/IO fails):
#   {"reviewed":true,"head_sha":"...","verdict":"...","session":"...","reviewed_at":"...","age_min":N}
#   {"reviewed":false,"reason":"no-marker"}      -> never reviewed by this loop
#   {"reviewed":false,"reason":"sha-changed","marker_sha":"...","head_sha":"..."}
#     -> reviewed, but the author has pushed since; review it again
#
# Why keyed by head SHA: it makes the marker self-invalidating. A new push
# produces a new SHA, so the PR becomes reviewable again with no expiry logic
# and no cleanup step, while a PR nobody has touched since its review stays
# skipped. Time-based markers would either re-review unchanged PRs or suppress
# review of freshly pushed ones.
#
# The claim ledger (claim-pr.sh) and this reviewed ledger answer different
# questions: "is someone reviewing this right now" versus "has this exact
# commit already been reviewed". Concurrent collisions need the first;
# back-to-back duplicate work needs the second.
#
# Env: PR_REVIEW_DONE_DIR (default ~/.claude/thoughts/shared/pr-review-done)
set -uo pipefail

usage() {
  echo "usage: check-reviewed.sh <owner> <repo> <number> --sha <head_sha>" >&2
  exit 1
}

[ $# -ge 3 ] || usage
owner="$1"
repo="$2"
number="$3"
shift 3

sha=""
while [ $# -gt 0 ]; do
  case "$1" in
    --sha)
      shift
      [ $# -gt 0 ] || usage
      sha="$1"
      ;;
    *) usage ;;
  esac
  shift
done

[ -n "$sha" ] || usage
case "$number" in
  '' | *[!0-9]*) usage ;;
esac

dir="${PR_REVIEW_DONE_DIR:-$HOME/.claude/thoughts/shared/pr-review-done}"
file="$dir/${owner}__${repo}__${number}.json"

if [ ! -e "$file" ]; then
  jq -nc '{reviewed: false, reason: "no-marker"}'
  exit 0
fi

marker_sha=$(jq -r '.head_sha // ""' "$file" 2>/dev/null || echo "")

if [ "$marker_sha" != "$sha" ]; then
  # Includes the unparseable-marker case (marker_sha empty): treat as not
  # reviewed and let the run review the PR. Erring toward a redundant review
  # is strictly safer than silently skipping one.
  jq -nc --arg marker_sha "$marker_sha" --arg head_sha "$sha" \
    '{reviewed: false, reason: "sha-changed", marker_sha: $marker_sha, head_sha: $head_sha}'
  exit 0
fi

now=$(date -u +%s)
at_epoch=$(jq -r '.reviewed_at_epoch // 0' "$file" 2>/dev/null || echo 0)
case "$at_epoch" in
  '' | *[!0-9]*) at_epoch=$now ;;
esac

jq -nc \
  --arg head_sha "$marker_sha" \
  --arg verdict "$(jq -r '.verdict // "unknown"' "$file" 2>/dev/null || echo unknown)" \
  --arg session "$(jq -r '.session // "unknown"' "$file" 2>/dev/null || echo unknown)" \
  --arg reviewed_at "$(jq -r '.reviewed_at // "unknown"' "$file" 2>/dev/null || echo unknown)" \
  --argjson age_min "$(( (now - at_epoch) / 60 ))" \
  '{reviewed: true, head_sha: $head_sha, verdict: $verdict, session: $session,
    reviewed_at: $reviewed_at, age_min: $age_min}'
