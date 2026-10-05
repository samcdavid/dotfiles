---
effort: high
name: loop-plan
description: "Plan a project conversationally from idea to MVP milestones to Linear issues — each milestone 5–6 tasks ending in a user-facing demo, each task one /my-loop — broken down and written to Linear one milestone at a time."
---

# Loop Plan

Plan a project the way `my-loop` builds one: as a conversation that moves
through three levels, idea → milestones → tasks, rather than a researched
package presented for one big approval. Each level is settled with the user
before the next begins, and breaking down a milestone may revise the outline
when it teaches something new.

`team-plan` remains the route for large multi-person efforts that need parallel
lanes, conflict matrices, and per-issue commit plans.

## Shape of the plan

- **Milestones are small MVP increments.** Each ships something meaningful and
  ends in a user-facing demo: a short script a user could follow to see the new
  capability work. The first milestone is the thinnest end-to-end slice that
  delivers real value; later milestones widen it. Merged code, a status update,
  or a technical-only proof is not a demo.
- **Each milestone holds 5–6 tasks.** Never more than six: split into two
  demoable milestones instead. Fewer is acceptable only when the demo genuinely
  needs fewer — say why; never add filler.
- **Each task is one PR delivered by one `/my-loop` run.** It states the
  user-visible outcome, acceptance criteria, what it contributes to the
  milestone demo, out-of-scope behavior, rough surfaces touched, and its
  blockers. No commit plan — `my-loop` discovers slices as it builds.
- **Every prerequisite is an explicit blocker edge**, never prose or assumed
  order. No cycles.

## Load Rules

Already loaded as memory under Claude Code — apply without re-reading:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/human-readable-communication.md`

Under Codex, read the `~/.agents/rules/` equivalents explicitly. Always read
`references/protocol.md`; use `references/project-log-template.md` when
creating a log.

## Flow

1. **Idea.** Agree on the problem, who has it, what the MVP must prove, and
   non-goals. Orient briefly in the code when a repository is in scope.
2. **Milestone outline.** Propose ordered milestones, each with a goal, what it
   ships, and its demo script — no tasks yet. Iterate until the user confirms.
3. **Break down one milestone at a time**, in order. Draft its tasks, discuss
   them, then present the exact Linear changes for that milestone and write
   them only after explicit approval. Verify, record IDs, move to the next.
4. **Done** when every milestone is in Linear. Return the project summary.

Ask one load-bearing decision per turn, with a recommendation. Resolve facts
from code, Linear, and docs instead of asking. Never write to Linear without
approval of the exact changes for the current milestone.

## Output

Each turn: the log delta, the current level's surface (idea, outline, or the
milestone being broken down), and the single next decision. Keep the log path
visible. Lead with milestone names, demos, and task outcomes in plain language;
never make the user decode log keys or Linear IDs.
