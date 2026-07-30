#!/usr/bin/env bash
# Discover open PRs where review is requested from the authenticated user,
# across every repo they can see, excluding anything already approved.
#
# Usage: discover-review-queue.sh
# Output: one JSON object per line (NDJSON) — owner, repo, number, title,
#         url, draft. Empty output means nothing left to review.
#
# Uses `gh search prs`, not `gh pr list` — `gh pr list` only lists one repo
# at a time (`-R owner/repo`); `gh search prs --review-requested=@me`
# searches every repo the account can see in one call. A reviewer's queue
# routinely spans repos, so a single-repo list would silently miss some.
#
# "review-requested:@me" alone is not a reliable filter: GitHub can leave or
# re-add a PR to that queue after an approval (e.g. new commits under a
# branch-protection rule that dismisses stale reviews). This script checks
# each candidate's actual latest review state from this user and drops it
# unconditionally if that state is APPROVED — even if new commits landed
# since. The point of discovery is to surface what still needs a look, not
# to re-litigate something already signed off on.
set -uo pipefail

if ! gh auth status >/dev/null 2>&1; then
  echo "discover-review-queue.sh: gh is not authenticated (run 'gh auth login')" >&2
  exit 1
fi

ME=$(gh api user --jq .login)

CANDIDATES=$(gh search prs --review-requested=@me --state=open \
  --json repository,number,title,url,isDraft 2>/dev/null)

echo "$CANDIDATES" | jq -c '.[]' | while IFS= read -r pr; do
  full_name=$(jq -r '.repository.nameWithOwner' <<<"$pr")
  owner="${full_name%%/*}"
  repo="${full_name##*/}"
  number=$(jq -r '.number' <<<"$pr")

  last_state=$(gh api "repos/${owner}/${repo}/pulls/${number}/reviews" 2>/dev/null \
    | jq -r --arg me "$ME" '[.[] | select(.user.login == $me)] | sort_by(.submitted_at) | last | .state // "NONE"')

  if [ "$last_state" = "APPROVED" ]; then
    continue
  fi

  jq -c --arg owner "$owner" --arg repo "$repo" \
    '{owner: $owner, repo: $repo, number, title, url, draft: .isDraft}' <<<"$pr"
done
