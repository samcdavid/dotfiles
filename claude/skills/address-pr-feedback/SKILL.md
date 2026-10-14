---
name: address-pr-feedback
description: "Work through PR review comments or local review findings: verify each, fix or push back with evidence, commit fixes, and draft replies."
effort: xhigh
---

Target: `$ARGUMENTS` (a PR number/URL, or review findings from this conversation; with findings there are no GitHub calls at all).

**Fetch** unresolved threads, keeping only the fields needed:

```bash
gh api graphql -F owner=OWNER -F name=REPO -F number=N -f query='
query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){
 headRefOid reviews(last:50){nodes{author{login} state submittedAt}}
 reviewThreads(first:100){nodes{id isResolved isOutdated path line
  comments(first:50){nodes{fullDatabaseId author{login} body}}}}}}}' \
 --jq '.data.repository.pullRequest | {headRefOid, reviews: .reviews.nodes, threads: [.reviewThreads.nodes[] | select(.isResolved|not)]}'
```

Fetch review bodies or issue comments only if feedback lives there. A reply that already cites a fix commit counts as addressed.

**Triage** each comment in code context. Verify the reviewer's claim (does the helper exist, does the bug reproduce, does the convention actually hold?), then classify it as Fix, Partially correct, Question, Push back (with evidence: code, output, docs), Defer (adjacent, not intrinsic to this PR), or Already addressed. Group comments that share a root cause into one fix. For DRY requests, count occurrences: three or fewer usually means push back. If the safe fix would cut a required behavior, stop and ask me; don't gate it off. For a disputed design pushback, challenge it with the `adversarial-debate` agent first. Don't turn "address feedback" into "implement every suggestion."

**Show me** the triage and planned fixes, then make the fixes yourself: small commits following `~/.gitmessage`, running the narrow tests for each. A comment you add or edit states the present-day why (`~/.claude/rules/comment-style.md`), never the review history behind the fix; that goes in the reply and commit message.

**Draft replies**: concise, cite the fix SHA or the evidence, no over-apologizing, no bare "no."

**Publish only when I say so**, in this order:
1. `git push`. If it fails, stop.
2. Reply to inline comments with `gh api repos/O/R/pulls/N/comments -f body=… -F in_reply_to=ID`. Feedback in review bodies or issue comments gets a quoted reply via `issues/N/comments`.
3. Resolve each thread you replied to (`resolveReviewThread`).
4. Re-request review (`gh pr edit N --add-reviewer …`) from people you replied to. Skip anyone whose latest review is APPROVED.

Report each failure and continue.
