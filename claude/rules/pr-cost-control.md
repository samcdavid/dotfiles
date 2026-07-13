# PR Cost Control

Use this when fetching PR review data, addressing PR feedback, publishing review replies, or validating PR fixes.

## Fetch Shape

Filter GitHub payloads before they enter context. Never ingest raw REST review/comment objects unless debugging the API itself.

Prefer a scoped GraphQL review-thread fetch for inline threads and resolution state:

```bash
OWNER_REPO=$(gh repo view --json owner,name --jq '"\(.owner.login) \(.name)"')
OWNER=${OWNER_REPO% *}
REPO=${OWNER_REPO#* }

gh api graphql \
  -f owner="$OWNER" \
  -f name="$REPO" \
  -F number="$PR" \
  -f query='
query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      headRefOid
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          comments(first: 50) {
            nodes {
              id
              fullDatabaseId
              author { login }
              body
              createdAt
              outdated
              diffHunk
              replyTo { fullDatabaseId }
            }
          }
        }
      }
    }
  }
}' \
  --jq '.data.repository.pullRequest | {
    headRefOid,
    threads: [.reviewThreads.nodes[] | {
      thread_id: .id,
      is_resolved: .isResolved,
      is_outdated: .isOutdated,
      path,
      line,
      comments: [.comments.nodes[] | {
        id: .fullDatabaseId,
        node_id: .id,
        user: .author.login,
        body,
        created_at: .createdAt,
        outdated,
        diff_hunk: .diffHunk,
        in_reply_to_id: .replyTo.fullDatabaseId
      }]
    }]
  }'
```

For REST fallbacks, always project only needed fields:

```bash
gh api "repos/$OWNER/$REPO/pulls/$PR/comments" --paginate \
  --jq '[.[] | {id, user: .user.login, path, line, side, start_line, start_side, body, in_reply_to_id, commit_id, diff_hunk, outdated, created_at, updated_at}]'

gh api "repos/$OWNER/$REPO/pulls/$PR/reviews" --paginate \
  --jq '[.[] | {id, user: .user.login, state, body, submitted_at, commit_id}]'

gh api "repos/$OWNER/$REPO/issues/$PR/comments" --paginate \
  --jq '[.[] | {id, user: .user.login, body, created_at, updated_at}]'
```

Use raw payloads only after a filtered fetch proves a required field is missing.

## Context Discipline

- If a tool compresses a payload, retrieve only the relevant slice by query; do not pull the whole raw object back.
- Batch reads for a file investigation. Read the file and nearby tests once, then work from that snapshot.
- Do not immediately re-read a file after editing just to check your edit; use `git diff`, targeted tests, or compiler output.

## Validation Discipline

- Run the narrowest affected test/check first while iterating.
- Run broader package/domain/full-suite checks once at the end, not after every small fix.
- To decide whether a warning is yours, first intersect warning paths with `git diff --name-only`. Avoid stash/recompile cycles unless path attribution is ambiguous.
