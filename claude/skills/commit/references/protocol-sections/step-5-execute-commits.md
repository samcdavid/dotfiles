## Step 5 — Execute Commits

After confirmation, execute each commit in order. For each commit:

1. Stage only the files for that commit using explicit paths (`git add path/to/file.ext`)
2. Commit with the full message:

```bash
git commit -m "$(cat <<'EOF'
<full commit message>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

3. Report the result before proceeding to the next:
```
Committed [1/N]: <short SHA> <subject line>
Files: <N> changed, <insertions> insertions(+), <deletions> deletions(-)
```

If `--amend` was requested and there is only one commit, use `git commit --amend`. Warn if the previous commit has already been pushed. `--amend` is incompatible with multi-commit plans — if both are present, warn and ask how to proceed.

After all commits, show a summary:
```
### Done — [N] commits created
1. <short SHA> <subject line>
2. <short SHA> <subject line>
```
