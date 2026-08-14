#!/usr/bin/env bash
# GitHub activity for a single day, grouped by PR.
#
# Usage: github-activity.sh [YYYY-MM-DD]   (defaults to today, local date)
#
# Uses the authenticated user's GitHub events feed (`users/:login/events`)
# rather than `gh search prs --updated=...`, because `updated` reflects the
# PR's last-touch time by anyone (CI, other reviewers) — it is not a per-day
# filter on *this user's* action. The events feed has real per-action
# timestamps for opens/merges/reviews/comments/pushes.
#
# Caveat: the events feed caps at ~300 events over the last ~90 days. On an
# unusually high-volume day this script may miss early events once the cap
# is hit; it is a best-effort daily digest, not an audit log.
set -uo pipefail

DATE="${1:-$(date +%Y-%m-%d)}"

if ! gh auth status >/dev/null 2>&1; then
  echo "github-activity.sh: gh is not authenticated (run 'gh auth login')" >&2
  exit 1
fi

USER_LOGIN=$(gh api user --jq .login)
EVENTS=$(gh api "users/${USER_LOGIN}/events?per_page=100" --paginate 2>/dev/null \
  | jq --arg date "$DATE" '[.[] | select(.created_at | startswith($date))]')

echo "# GitHub activity — $DATE"
echo

echo "## Pull requests touched"
PR_KEYS=$(jq -r '
  .[] | select(.type=="PullRequestEvent" or .type=="PullRequestReviewEvent" or .type=="PullRequestReviewCommentEvent")
  | "\(.repo.name)#\(.payload.pull_request.number)"
' <<<"$EVENTS")
PR_KEYS_FROM_ISSUES=$(jq -r '
  .[] | select(.type=="IssueCommentEvent" and (.payload.issue.pull_request != null))
  | "\(.repo.name)#\(.payload.issue.number)"
' <<<"$EVENTS")
ALL_PR_KEYS=$(printf '%s\n%s\n' "$PR_KEYS" "$PR_KEYS_FROM_ISSUES" | sort -u | grep -v '^$')

if [ -z "$ALL_PR_KEYS" ]; then
  echo "(none)"
else
  while IFS= read -r key; do
    repo="${key%%#*}"
    num="${key##*#}"

    pr_json=$(gh api "repos/${repo}/pulls/${num}" --jq '{title, html_url, merged}' 2>/dev/null) || continue
    title=$(jq -r .title <<<"$pr_json")
    url=$(jq -r .html_url <<<"$pr_json")

    actions=$(jq -r --arg repo "$repo" --arg num "$num" '
      .[] |
      if .type=="PullRequestEvent" and .repo.name==$repo and ((.payload.pull_request.number|tostring)==$num) then
        .payload.action
      elif .type=="PullRequestReviewEvent" and .repo.name==$repo and ((.payload.pull_request.number|tostring)==$num) then
        "reviewed:\(.payload.review.state)"
      elif .type=="PullRequestReviewCommentEvent" and .repo.name==$repo and ((.payload.pull_request.number|tostring)==$num) then
        "review_comment"
      elif .type=="IssueCommentEvent" and .repo.name==$repo and ((.payload.issue.number|tostring)==$num) then
        "comment"
      else empty end
    ' <<<"$EVENTS" | sort -u | paste -sd, -)

    echo "- ${repo}#${num} ${title} [${actions}] ${url}"
  done <<<"$ALL_PR_KEYS"
fi
echo

echo "## Commits authored"
COMMITS=$(gh search commits --author=@me --author-date="$DATE" --json repository,sha,commit \
  --jq '.[] | "- \(.repository.fullName) \(.sha[0:7]) \(.commit.message | split("\n")[0])"' 2>/dev/null)
if [ -z "$COMMITS" ]; then
  echo "(none)"
else
  echo "$COMMITS"
fi
