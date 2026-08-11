#!/usr/bin/env bash
# Record that a PR has been reviewed at a specific head commit, so later
# sessions (and later iterations of this run) skip it instead of repeating the
# work. Pairs with check-reviewed.sh.
#
# Usage: mark-reviewed.sh <owner> <repo> <number> --sha <head_sha> \
#          [--verdict <verdict>] [--session <id>]
# Output: {"marked":true,"head_sha":"...","path":"..."}
#
# Call this after publishing and *before* releasing the claim. Marking while
# the claim is still held means there is no instant where the PR is both
# unclaimed and unmarked — the exact window in which another session would
# pick it up and re-review it.
#
# Markers older than PR_REVIEW_DONE_TTL_DAYS (default 14) are pruned on each
# call, so the directory does not grow without bound. Pruning is opportunistic
# rather than scheduled: a stale marker is harmless (its SHA no longer matches
# anything live), it is only clutter.
#
# Env: PR_REVIEW_DONE_DIR, PR_REVIEW_DONE_TTL_DAYS, PR_REVIEW_SESSION.
set -uo pipefail

usage() {
  echo "usage: mark-reviewed.sh <owner> <repo> <number> --sha <head_sha> [--verdict <v>] [--session <id>]" >&2
  exit 1
}

[ $# -ge 3 ] || usage
owner="$1"
repo="$2"
number="$3"
shift 3

sha=""
verdict="unknown"
session="${PR_REVIEW_SESSION:-}"
while [ $# -gt 0 ]; do
  case "$1" in
    --sha)
      shift
      [ $# -gt 0 ] || usage
      sha="$1"
      ;;
    --verdict)
      shift
      [ $# -gt 0 ] || usage
      verdict="$1"
      ;;
    --session)
      shift
      [ $# -gt 0 ] || usage
      session="$1"
      ;;
    *) usage ;;
  esac
  shift
done

[ -n "$sha" ] || usage
[ -n "$session" ] || session="unknown-$$"
case "$number" in
  '' | *[!0-9]*) usage ;;
esac

dir="${PR_REVIEW_DONE_DIR:-$HOME/.claude/thoughts/shared/pr-review-done}"
mkdir -p "$dir" || exit 1
file="$dir/${owner}__${repo}__${number}.json"
tmp="${file}.tmp.$$"
trap 'rm -f "$tmp"' EXIT

now=$(date -u +%s)

# Written via temp file + rename so a concurrent check-reviewed.sh never sees a
# half-written marker (same hazard claim-pr.sh guards against). Unlike a claim,
# a marker has no exclusivity requirement, so a plain atomic replace is right.
jq -nc \
  --arg owner "$owner" \
  --arg repo "$repo" \
  --argjson number "$number" \
  --arg head_sha "$sha" \
  --arg verdict "$verdict" \
  --arg session "$session" \
  --arg reviewed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson reviewed_at_epoch "$now" \
  '{owner: $owner, repo: $repo, number: $number, head_sha: $head_sha,
    verdict: $verdict, session: $session, reviewed_at: $reviewed_at,
    reviewed_at_epoch: $reviewed_at_epoch}' > "$tmp" || exit 1
mv -f "$tmp" "$file" || exit 1

ttl_days="${PR_REVIEW_DONE_TTL_DAYS:-14}"
case "$ttl_days" in
  '' | *[!0-9]*) ttl_days=14 ;;
esac
find "$dir" -maxdepth 1 -name '*.json' -type f -mtime "+${ttl_days}" -delete 2>/dev/null

jq -nc --arg head_sha "$sha" --arg path "$file" \
  '{marked: true, head_sha: $head_sha, path: $path}'
