## Step 12 — Publish Responses

Only after user confirmation. Push any new commits first, then post responses.

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

### Publish Order

1. Push commits first — so commit SHA links in responses resolve correctly
2. Thread replies next — these are the most targeted and expected
3. PR-level replies last

### Error Handling

- If a thread reply fails (e.g. comment ID no longer exists), report the error and fall back to a PR-level comment quoting the original
- If a push fails, do NOT post responses — commit SHAs in responses would be wrong
- Report each posted response as it succeeds so the user can track progress
