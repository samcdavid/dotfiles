# Replies and Publishing

Load this when drafting or publishing reviewer replies.

Reply shape:

- Acknowledge the reviewer concern.
- State what changed or why no code change was made.
- Cite evidence: tests, files, docs, requirements, or command output.
- Keep pushback falsifiable and respectful.

Publishing rules:

- Inline review comments reply in-thread using the original comment ID.
- Review-body or issue comments get a normal PR conversation reply with quoted context.
- Push commits, publish replies, mark their threads resolved, and re-request review from the reviewers who left them — all automatically once verification and self-audit pass. The Step 2 triage confirmation is the explicit request (`no-outward-actions.md`) that authorizes this for the whole run. Never force CI.

## Publish Mechanics

Runs automatically once Step 9 (verification) and Step 10 (self-audit) pass — Step 2's triage confirmation already authorized this. Push any new commits first, then post responses, then resolve threads, then re-request review.

### Push Commits

```bash
git push
```

### Post Thread Replies

For each response targeting an inline review comment (has a `comment_id`):

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  -f body="Response text" \
  -F in_reply_to={comment_id}
```

### Post PR-Level Replies

For each response targeting a review body or issue comment (no `comment_id`):

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments \
  -f body="> Quoted original text

Response text"
```

### Resolve Threads

For each `review_comment` item that just received a reply and has a `thread_id` (captured in Step 1's index), mark the thread resolved:

```bash
gh api graphql -f threadId="{thread_id}" -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { id isResolved }
  }
}'
```

`review_body` and `issue_comment` replies have no GraphQL review thread to resolve — skip them.

### Re-request Reviews

Once every reply is posted and its thread resolved, re-request review from each unique reviewer who appears in Step 1's pending-feedback index — the same people who just got a reply, so they're the ones with something new to look at. This is the same action as GitHub's "Re-request review" button and works regardless of the reviewer's prior state (APPROVE, COMMENTED, CHANGES_REQUESTED):

```bash
gh pr edit {number} --add-reviewer {login1},{login2}
```

Skip a reviewer only if they're the PR author (can't review their own PR) or no longer has repo access — report and continue rather than failing the whole batch.

### Publish Order

1. Push commits first — so commit SHA links in responses resolve correctly
2. Thread replies next — these are the most targeted and expected
3. PR-level replies last
4. Resolve threads next — only after the reply addressing each thread has actually posted
5. Re-request reviews last — reviewers should see the finished, resolved state when they get the notification

### Error Handling

- If a thread reply fails (e.g. comment ID no longer exists), report the error and fall back to a PR-level comment quoting the original
- If a push fails, do NOT post responses — commit SHAs in responses would be wrong
- If resolving a thread fails (e.g. already resolved, stale ID), report it and continue — a resolve failure never blocks other replies or a prior push
- If re-requesting a reviewer fails (e.g. no repo access, removed from the org), report it and continue with the rest
- Report each posted response, resolved thread, and re-requested reviewer as it succeeds so the user can track progress

