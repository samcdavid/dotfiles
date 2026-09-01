# No Outward Actions

Default boundary for personal workflows:

- Do not push, publish reviews or replies, create or update PRs, resolve threads, deploy, or mutate remote systems unless the user explicitly asks.
- Local file edits, local test runs, local git inspection, and local artifact writes are allowed when the task calls for them.
- If a workflow needs an outward action to continue, stop with the exact action, reason, and risk.

## Local Commits Are Not Outward

A local commit mutates nothing remote and is cheap to undo, so it is not gated by this rule. Implementation and fix phases **should** commit as they go, so a session leaves a reviewable history instead of one undifferentiated working tree.

Commit when a phase has passed its own validation, scoped to that phase's files, via the `commit` skill. `my-implement` commits each verified delegated phase; `my-quick` and `address-pr-feedback` ensure every completed phase or fix is committed.

Do not commit a phase that failed validation or escalated — leave it in the working tree for inspection. Never `git push` as part of this; the branch stays local until the user asks.
