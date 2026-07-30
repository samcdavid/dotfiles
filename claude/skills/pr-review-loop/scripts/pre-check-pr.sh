#!/usr/bin/env bash
# Pre-check a single PR's state before reviewing it: merged (or otherwise
# closed) PRs get skipped, everything else proceeds.
#
# Usage: pre-check-pr.sh <owner> <repo> <number>
# Output: one JSON object: {"skip": bool, "reason": string|null, "draft": bool, "title": string}
#   skip=true,  reason="merged" -> PR has been merged; do not review
#   skip=true,  reason="closed" -> PR is closed without merging; do not review
#   skip=false, reason=null     -> safe to review (check "draft" for a note in the ledger)
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
  if .merged then
    {skip: true, reason: "merged", draft: .draft, title: .title}
  elif .state == "closed" then
    {skip: true, reason: "closed", draft: .draft, title: .title}
  else
    {skip: false, reason: null, draft: .draft, title: .title}
  end
' <<<"$pr_json"
