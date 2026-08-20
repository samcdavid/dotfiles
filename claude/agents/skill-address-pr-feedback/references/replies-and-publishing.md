# Replies and Publishing — skill-address-pr-feedback

Load this when drafting reviewer replies and constructing the wrapper's external-action envelope. The runner never executes these commands.

Reply shape:

- Acknowledge the reviewer concern.
- State what changed or why no code change was made.
- Cite evidence: tests, files, docs, requirements, or command output.
- Keep pushback falsifiable and respectful.

External-action envelope rules:

- Inline review comments reply in-thread using the original comment ID.
- Review-body or issue comments get a normal PR conversation reply with quoted context.
- Include pushes, replies, thread resolution, and review re-requests only as named proposed actions with the targets, drafts, evidence, and order below. The wrapper independently checks explicit authorization before it executes any of them. Never force CI.

## Wrapper action mechanics

After Step 9 (validation/review) and Step 11 (self-audit) pass, return this exact ordering in `external_action_requested`; do not run it. The wrapper may push commits first, then post responses, resolve threads, then re-request review only after matching each item to explicit user authorization.

### Push commits (wrapper only)

```bash
git push
```

### Post thread replies (wrapper only)

For each response targeting an inline review comment (has a `comment_id`):

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  -f body="Response text" \
  -F in_reply_to={comment_id}
```

### Post PR-level replies (wrapper only)

For each response targeting a review body or issue comment (no `comment_id`):

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments \
  -f body="> Quoted original text

Response text"
```

### Resolve threads (wrapper only)

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

### Re-request reviews (wrapper only)

Once every reply is posted and its thread resolved, re-request review from each unique reviewer who appears in Step 1's pending-feedback index — the same people who just got a reply, so they're the ones with something new to look at. This is the same action as GitHub's "Re-request review" button:

```bash
gh pr edit {number} --add-reviewer {login1},{login2}
```

**Never re-request a reviewer whose latest review on this PR is APPROVE.** Check `reviews` (fetched in Step 1, sorted by `submittedAt`) for each candidate's most recent state before adding them to the batch — an approval means they've already signed off, and pinging them again reopens a decision they made, not a request for a fresh look. Only reviewers whose latest state is COMMENTED or CHANGES_REQUESTED (or who never reviewed at all but still left a comment) are eligible.

Also skip a reviewer if they're the PR author (can't review their own PR) or no longer has repo access — report and continue rather than failing the whole batch.

### Required envelope order

1. Push commits first — so commit SHA links in responses resolve correctly
2. Thread replies next — these are the most targeted and expected
3. PR-level replies last
4. Resolve threads next — only after the reply addressing each thread has actually posted
5. Re-request reviews last — reviewers should see the finished, resolved state when they get the notification

### Wrapper error handling

- If a thread reply fails (e.g. comment ID no longer exists), report the error and fall back to a PR-level comment quoting the original
- If a push fails, do NOT post responses — commit SHAs in responses would be wrong
- If resolving a thread fails (e.g. already resolved, stale ID), report it and continue — a resolve failure never blocks other replies or a prior push
- If re-requesting a reviewer fails (e.g. no repo access, removed from the org), report it and continue with the rest
- The wrapper reports each posted response, resolved thread, and re-requested reviewer as it succeeds so the user can track progress.
