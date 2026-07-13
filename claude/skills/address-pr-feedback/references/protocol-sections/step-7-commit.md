## Step 7 — Commit

Unlike `my-implement` (which commits nothing — executors only produce working-tree changes), this skill **does** commit, because responses reference commit SHAs. Group related fixes into logical commits; each message references the feedback:

```
Address review: [brief description of what changed]

- [reviewer]'s feedback on file:line — [what was fixed]
- [reviewer]'s suggestion on file:line — [what was changed]
```

After each commit, note the short SHA — you'll use it in responses.

---

# Tail — Respond, Verify, Publish
