## Step 6 — Post to PR (if requested)

If the user wants results posted to the PR:

1. Post the results table as an issue comment:
```bash
gh api repos/{owner}/{repo}/issues/{number}/comments -f body="$(cat <<'EOF'
[results table from Step 5]
EOF
)"
```

2. Tell the user the GIF location (`~/Downloads/PR-<number>/...`) so they can manually upload it to the PR comment (GitHub doesn't support CLI image uploads to comments).
