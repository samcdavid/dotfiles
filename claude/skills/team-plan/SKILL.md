---
model: opus
name: team-plan
description: Discover and scope a project, research its codebase gap, then draft a low-overlap Linear milestone and issue plan for parallel PR delivery.
disable-model-invocation: false
---

# Team Plan

Turn a project proposal, an existing Linear project/milestone, or an issue set into an evidence-backed delivery plan. Start with product discovery and requirements, then research the codebase to identify the existing behavior and the gap. Define job stories, PR-sized issues, milestones, dependencies, and a parallel execution plan. The final plan is a draft until the user explicitly approves Linear creation or updates.

Use the stated team size when available. Otherwise plan for up to eight parallel PR-sized issues; target six to eight independent issues in a normal feature wave when the work supports it. Do not invent or split work merely to meet that target. If the safe parallelism is lower, explain the concrete dependency or shared surface that limits it.

## Load Rules

Read `~/.claude/rules/question-policy.md` and `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. Read `references/protocol.md` for the full discovery, research, issue-design, and Linear workflow. When the project may change persisted data or schema in an Ecto application, also read `references/migration-planning.md`.

## Flow

1. Gather and verify requirements, including the new user-visible functionality, constraints, non-goals, and unresolved product decisions.
2. Research the relevant codebase, deployed behavior, prior work, and existing Linear work; map each requirement to current evidence and a concrete gap.
3. Express the work as job stories, then define one independently reviewable PR-backed issue for each coherent delivery unit.
4. Isolate database migration work from functional work, and sequence every dependent functional issue after its migration-only issue is safely deployed.
5. Identify surfaces, dependencies, and merge conflicts; arrange milestones and waves for the maximum safe parallelism with minimal overlap. Generated code alone is not an overlap.
6. Present the complete draft and obtain explicit approval before creating or changing any Linear project, milestone, issue, relationship, or comment.

## Output

Return the requirements brief, evidence-backed gap map, job stories, PR-backed issue drafts, migration plan where applicable, milestones/waves, dependency and conflict analysis, and the exact Linear changes awaiting approval.
