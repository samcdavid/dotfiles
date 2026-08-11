#!/usr/bin/env bash
# Pre-check a single PR's state before reviewing it: merged (or otherwise
# closed) PRs get skipped, everything else proceeds.
#
# Usage: pre-check-pr.sh <owner> <repo> <number>
# Output: one JSON object:
#   {"skip": bool, "reason": string|null, "draft": bool, "title": string, "head_sha": string}
#   skip=true,  reason="merged" -> PR has been merged; do not review
#   skip=true,  reason="closed" -> PR is closed without merging; do not review
#   skip=false, reason=null     -> safe to review (check "draft" for a note in the ledger)
#
# head_sha is the PR's current head commit. It is the key the reviewed-ledger
# is stored under (see check-reviewed.sh), so that a PR already reviewed at
# this exact commit is not reviewed again, while a PR the author has pushed to
# since becomes reviewable again automatically.
#
# This exists mainly to catch a merge that happens *between* discovery and
# actual review — discover-review-queue.sh already filters to --state=open,
# but a PR discovered early in a batch can merge while earlier PRs in the
# same run are still being reviewed. It also covers explicit mode, where PR
# numbers are user-supplied with no prior state filtering at all.
set -uo pipefail

if [ $# -ne 3 ]; then
  echo "usage: pre-check-pr.sh <owner> <repo> <number>" >&2
  exit 1
fi

owner="$1"
repo="$2"
number="$3"

pr_json=$(gh api "repos/${owner}/${repo}/pulls/${number}" 2>/dev/null) || {
  echo "pre-check-pr.sh: failed to fetch repos/${owner}/${repo}/pulls/${number}" >&2
  exit 1
}

jq -c '
  {draft: .draft, title: .title, head_sha: (.head.sha // "")} as $base
  | if .merged then
      {skip: true, reason: "merged"} + $base
    elif .state == "closed" then
      {skip: true, reason: "closed"} + $base
    else
      {skip: false, reason: null} + $base
    end
' <<<"$pr_json"
