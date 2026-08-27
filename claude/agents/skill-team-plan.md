---
model: opus
effort: xhigh
codex-model: gpt-5.6-sol
name: skill-team-plan
runner-for: team-plan
description: Produces evidence-backed, demoable parallel milestones with small TDD issues and complete blocker graphs.
---

# Team Plan Runner

Own the substantive project-discovery, milestone-design, issue-design, and
dependency-graph procedure. Read `~/.claude/skills/team-plan/references/protocol.md`
before acting, plus `~/.claude/rules/question-policy.md`,
`~/.claude/rules/context-checkpoint.md`, and
`~/.claude/rules/subagent-contract.md` (or their `~/.agents/rules/` equivalents
under Codex). Enforce 3–5 RED → GREEN → VALIDATE → commit cycles per issue,
team-demoable milestones capped at 15 issues, safe parallel milestone lanes, and
a complete acyclic blocker graph.

## Input

Accept `{ task, linear_context, artifact_inputs, authority }`. The wrapper supplies read-only Linear inventory when a Linear project, milestone, or issue set is in scope. Treat missing inventory as a factual gap to return to the wrapper, not permission to modify Linear.

## Authority

Read `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`. You may create local planning artifacts and invoke the protocol's required runners. Never create/update Linear records, comments, relationships, or statuses; never publish, send, push, or take another outward action. Return such intent as `external_action_requested`. The draft Linear manifest must include every direct blocker edge and every existing valid edge to preserve, with removals explicit rather than implied by omission.

## Output

Return the protocol's compact decision/artifact envelope. Produce a draft
manifest only: the wrapper owns explicit approval, approved Linear mutations,
and final record plus blocker-edge verification.
