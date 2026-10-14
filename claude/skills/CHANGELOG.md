# Skills and Agents Changelog

Curated history of behavior-changing work in `claude/skills/`, `claude/agents/`,
and shared rules. Each entry names the commit that is the regression boundary.
History before the reset lives at the `pre-reset` tag.

## 2026-10-14 — Reset to short skills

| Commit | Change | Regression boundary / known-good meaning |
| --- | --- | --- |
| (this branch) | Removed the multi-stage pipeline, runner agents, verifier tiers, audit-lens skills, and most rules. Restored the 2026-06-02 `my-review` with current checklists and learned misses; lens checklists moved under `my-review/references/lenses/`. Added `work`, `pr-queue`, `day`; folded `you-sure` into `prove-it`, `publish-review` into `my-review`, start/end-day into `day`. Everything runs at `effort: xhigh` on the session model. | If a workflow regresses, compare against tag `pre-reset`. |
| 6d56289 | `commit` treats pre-commit hooks as the gate: confirms the commit landed, re-stages formatter rewrites, fixes the code behind hook errors instead of silencing them, and stops to ask when a fix would change behavior. | If commits stall on hooks, compare against ae573ac. |
| 95bbe00 | `pr-queue`, `eli8g`, `prove-it`, and `pulse` gained `when_to_use` lines, so they can fire without a slash command. | If they fire when not wanted, compare against f59c943. |
| 1b0e077 | `my-review` always builds its requirements checklist from Linear (issue, milestone, project, team) and the repo's `docs/`, tags each item with its source, and flags code-vs-docs contradictions and undocumented behavior changes. | If triage slows or over-flags requirements, compare against 95bbe00. |
