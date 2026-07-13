## Step 6 — Regression Risk Annotations

Using the conflict matrix, identify the tests most likely to break when issues from the same wave (or adjacent waves) merge. For each HIGH or MED conflict pair, note what the implementer of one issue should watch for when the other lands:

```markdown
### ENG-123 × ENG-456 (HIGH — shared: user.ex:changeset/2)
- ENG-123 implementer: re-run user creation tests after ENG-456 merges
- ENG-456 implementer: if you change changeset/2's return shape, ENG-123's tests will fail

### ENG-789 × ENG-234 (MED — shared: router.ex)
- Both add routes in the same section; merge order matters, verify no duplicate paths
```

Save to `~/.claude/thoughts/shared/plans/NNN_regression_risks_{milestone_slug}.md`.
