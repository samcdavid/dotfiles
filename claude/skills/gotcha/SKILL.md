---
name: gotcha
description: Capture a failure pattern or anti-pattern as a gotcha for an existing skill. Use when Claude makes a mistake, the user corrects an approach, or a non-obvious pattern is discovered. Builds up institutional knowledge over time.
disable-model-invocation: false
---

# Capture Gotcha

Capture a failure pattern, anti-pattern, convention, or edge case and persist it so future work avoids the same mistake.

## Getting Started

If invoked explicitly, ask what went wrong or what was learned. If invoked after a correction, use conversation context to identify the gotcha.

## Step 1 — Identify the Gotcha

Review the conversation to determine:
1. **What went wrong** (or what non-obvious thing was learned)
2. **Which skill it applies to** — ask if ambiguous. Valid targets are any skill directory under `~/.dotfiles/claude/skills/`.
3. **Category:**
   - `failure-mode` — Claude did X wrong
   - `anti-pattern` — code pattern to avoid
   - `convention` — non-obvious project rule
   - `edge-case` — surprising behavior

## Step 2 — Write the Gotcha

Append a structured entry to `~/.dotfiles/claude/skills/{skill}/gotchas.md`.

If `gotchas.md` doesn't exist for that skill, create it with:
```markdown
# Gotchas — {skill name}

Known failure patterns and lessons learned. Read before starting work with this skill.
```

Then append the entry:

```markdown
### [Short descriptive title]
- **Category:** failure-mode | anti-pattern | convention | edge-case
- **Context:** [When this comes up]
- **Wrong:** [What Claude did or what seems right but isn't]
- **Right:** [Correct approach]
- **Why:** [Root cause / reasoning]
- **Source:** [PR #, conversation, or discovery date]
```

## Rules

- **Append, don't overwrite** — gotchas accumulate over time
- **Be specific** — vague gotchas ("be careful with X") are useless. Include concrete wrong/right examples.
- **One gotcha per entry** — if multiple things went wrong, create multiple entries
- **De-duplicate** — read the existing gotchas.md first. Don't add something already captured. Update an existing entry if the new instance adds nuance.
