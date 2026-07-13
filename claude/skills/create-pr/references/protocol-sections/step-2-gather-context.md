## Step 2 — Gather Context

```bash
git diff <base>...HEAD
git log <base>..HEAD --format="%H%n%s%n%b%n---"
gh pr view --json baseRefName,headRefName    # if updating
```

Detect base branch: prefer the base from an existing PR; otherwise the repo default (`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`).

Parse the linked ticket from:
1. Branch name (e.g. `eng-123-add-foo` → `ENG-123`)
2. Commit messages (look for `ENG-123`, `Closes #N`, Linear URLs, "Related Cards" trailers)
3. Existing PR body (if updating)
