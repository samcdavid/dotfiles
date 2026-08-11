#!/usr/bin/env bash
# Release a PR claim taken by claim-pr.sh, so other sessions can pick the PR
# up again. Call this for every PR this session claimed — after publishing,
# and also after a skip or a terminal failure. A claim that is never released
# blocks that PR until its TTL expires.
#
# Usage: release-pr.sh <owner> <repo> <number> [--session <id>] [--force]
# Output: one JSON object (always exit 0 unless usage/IO fails):
#   {"released":true,"holder":"<id>","path":"..."}
#   {"released":false,"reason":"not-claimed",...}   -> nothing to release
#   {"released":false,"reason":"held-by-other",...} -> another session's claim;
#                                                      re-run with --force to
#                                                      remove it anyway
#
# The ownership check is why --session is worth passing: it stops a confused
# run from releasing a PR another session is actively reviewing. With no
# session id supplied (and none in PR_REVIEW_SESSION), the claim is removed
# unconditionally.
#
# Env: PR_REVIEW_SESSION, PR_REVIEW_CLAIM_DIR (see claim-pr.sh).
set -uo pipefail

usage() {
  echo "usage: release-pr.sh <owner> <repo> <number> [--session <id>] [--force]" >&2
  exit 1
}

[ $# -ge 3 ] || usage
owner="$1"
repo="$2"
number="$3"
shift 3

session="${PR_REVIEW_SESSION:-}"
force=false
while [ $# -gt 0 ]; do
  case "$1" in
    --session)
      shift
      [ $# -gt 0 ] || usage
      session="$1"
      ;;
    --force) force=true ;;
    *) usage ;;
  esac
  shift
done

case "$number" in
  '' | *[!0-9]*) usage ;;
esac

dir="${PR_REVIEW_CLAIM_DIR:-$HOME/.claude/thoughts/shared/pr-review-claims}"
file="$dir/${owner}__${repo}__${number}.json"

if [ ! -e "$file" ]; then
  jq -nc --arg path "$file" \
    '{released: false, reason: "not-claimed", holder: null, path: $path}'
  exit 0
fi

holder=$(jq -r '.session // "unknown"' "$file" 2>/dev/null || echo unknown)

if [ -n "$session" ] && [ "$holder" != "$session" ] && [ "$force" != true ]; then
  jq -nc --arg holder "$holder" --arg path "$file" \
    '{released: false, reason: "held-by-other", holder: $holder, path: $path}'
  exit 0
fi

rm -f "$file" || exit 1
jq -nc --arg holder "$holder" --arg path "$file" \
  '{released: true, reason: null, holder: $holder, path: $path}'
