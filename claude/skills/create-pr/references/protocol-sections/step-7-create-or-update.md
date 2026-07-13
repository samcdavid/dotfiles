## Step 7 — Create or Update

If the branch has no upstream (preflight noted this), push it first as part of the publish action — not as a separate prompt:
```bash
git push -u origin <branch>
```

**Create mode:**
```bash
gh pr create --title "<title>" --body-file <tmpfile> --base <base-branch> [--draft]
```

**Update mode:**
```bash
gh pr edit <number> --body-file <tmpfile> [--title "<title>"]
```

Show me the PR URL after.
