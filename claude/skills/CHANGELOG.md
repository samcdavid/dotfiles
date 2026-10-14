# Skills and Agents Changelog

Curated history of behavior-changing work in `claude/skills/`, `claude/agents/`,
and shared rules. Each entry names the commit that is the regression boundary.
History before the reset lives at the `pre-reset` tag.

## 2026-10-14 — Reset to short skills

| Commit | Change | Regression boundary / known-good meaning |
| --- | --- | --- |
| (this branch) | Removed the multi-stage pipeline, runner agents, verifier tiers, audit-lens skills, and most rules. Restored the 2026-06-02 `my-review` with current checklists and learned misses; lens checklists moved under `my-review/references/lenses/`. Added `work`, `pr-queue`, `day`; folded `you-sure` into `prove-it`, `publish-review` into `my-review`, start/end-day into `day`. Everything runs at `effort: xhigh` on the session model. | If a workflow regresses, compare against tag `pre-reset`. |
