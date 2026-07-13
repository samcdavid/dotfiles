## Step 3 — Context for Fixes

Before planning slices, build the context the fixes need:

- **Read every changed file fully** — not just the diff hunks. You need surrounding context to avoid introducing new problems while fixing old ones.
- **Spawn a codebase-pattern-finder** if any fix involves adding new code — check whether the codebase already has a utility or pattern for what's needed. Duplicating existing functionality while addressing feedback is a common second-round review finding.
- **Spawn a docs-researcher** if any fix involves library/framework APIs — even if you investigated in Step 2, confirm the exact usage pattern before writing the slice.
- **Check for interactions between fixes** — will fixing comment A conflict with fixing comment B? If two reviewers gave contradictory feedback, flag it for the user rather than choosing one silently.
