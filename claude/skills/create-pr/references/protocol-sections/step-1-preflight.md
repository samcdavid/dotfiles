## Step 1 — Preflight

Verify the branch is ready for a PR:

```bash
git status
git rev-parse --abbrev-ref HEAD
git log --oneline <base>..HEAD
```

Stop and report if:
- Working tree has uncommitted changes
- Branch is the base branch itself (no PR to make)
- No commits ahead of base
- Branch hasn't been pushed (`git rev-parse --abbrev-ref --symbolic-full-name @{u}` fails) — **but see the "Unpushed branch is not a hard stop" gotcha**: a brand-new feature branch on its first PR is the normal case, not misuse. Continue through Steps 2–6 and push as part of Step 7, not as a separate decision.

Detect existing PR for the branch:

```bash
gh pr view --json number,state,body,title,baseRefName,url
```

- Open PR → **update mode** (`gh pr edit ... --body-file`)
- Closed/merged PR → ask before creating a new one
- None → **create mode**
