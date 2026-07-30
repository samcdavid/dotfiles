#!/usr/bin/env bash
# Discover open PRs, in the current repo, where review is requested from the
# authenticated user and the user hasn't already approved.
#
# Usage: discover-review-queue.sh   (run from inside the target repo)
# Output: one JSON object per line (NDJSON) — owner, repo, number, title,
#         url, draft. Empty output means nothing left to review.
#
# Scope: the repo the current working directory belongs to, resolved via
# `gh repo view`. This deliberately does not search across repos — it
# tracks the repo the calling Claude session is actually working in.
#
# Exclusion, not a keep-list: a PR is dropped only if this user's *latest*
# review on it is APPROVED — nothing left to review once you've signed off.
# Never-reviewed (no review yet), COMMENTED, and CHANGES_REQUESTED are all
# kept — this surfaces both first-time review requests and PRs worth a
# second look after earlier feedback.
# "Latest" (not "ever") matters: GitHub can leave/re-add a PR to the
# review-requested queue after an approval (e.g. new commits under a
# branch-protection rule that dismisses stale reviews) — sort by
# submitted_at and check the last state, not whether an approval ever
# happened.
set -uo pipefail

if ! gh auth status >/dev/null 2>&1; then
  echo "discover-review-queue.sh: gh is not authenticated (run 'gh auth login')" >&2
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)
if [ -z "$REPO" ]; then
  echo "discover-review-queue.sh: not inside a GitHub repo (gh repo view failed)" >&2
  exit 1
fi

ME=$(gh api user --jq .login)

CANDIDATES=$(gh search prs --review-requested=@me --state=open --repo "$REPO" \
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
