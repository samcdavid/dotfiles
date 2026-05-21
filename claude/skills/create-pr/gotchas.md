# Gotchas — create-pr

Known failure patterns and lessons learned. Read before starting work with this skill.

### Unpushed branch is not a hard stop — push as part of the flow

- **Category:** failure-mode
- **Context:** Running `/create-pr` on a feature branch that has never been pushed to the remote (`git rev-parse --abbrev-ref --symbolic-full-name @{u}` fails).
- **Wrong:** Treating "no upstream" as a precondition failure and stopping at Step 1 to ask the user whether to push. The skill's preflight bullet "Branch hasn't been pushed" is meant to catch genuine misuse (running create-pr from a stale branch where the user forgot to commit/push, or from main), not the normal case of a brand-new branch on its first PR.
- **Right:** Continue through Steps 2–6 normally, show the PR title + body, get the user's approval, and **then** push with `git push -u origin <branch>` immediately before calling `gh pr create`. The push is part of the PR-creation flow, not a separate decision point.
- **Why:** The point of Step 6's approval gate is to control the visible action of publishing the PR. The push is mechanically required for `gh pr create` to succeed and is implicit in "create the PR." Asking about it separately splits one decision across two prompts and breaks the flow's rhythm — the user already approved publication when they approved the PR body.
- **Source:** Observed running `/create-pr` for the first PR on a fresh feature branch; the skill paused for permission to push instead of treating it as part of the publish action.
