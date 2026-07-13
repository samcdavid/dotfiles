## Step 5 — Review

Compute the diff scope:

```bash
base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
[ -z "$base" ] && { git show-ref --verify --quiet refs/heads/main && base=main || base=master; }
git diff --name-only "$base"...HEAD
```

Invoke `my-review` with the base branch name. Stay in local mode — no checkout, no PR. Let `my-review` do its own lens triage based on what the diff actually touches.
