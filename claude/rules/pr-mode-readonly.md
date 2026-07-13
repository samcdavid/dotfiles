# PR Mode Read-Only

When reviewing a GitHub PR:

- The PR diff and PR HEAD contents are source of truth.
- Do not check out, switch to, or fetch a PR into a named local branch.
- Do not read changed PR files from the local working tree as if they are PR contents.
- Full PR file contents must come from `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}`.
- `git fetch origin pull/N/head` without `:<name>` is acceptable only for unchanged history/context; it leaves `FETCH_HEAD`.

