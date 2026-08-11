---
model: opus
name: team-plan
description: Plan milestone work by analyzing issue surfaces, dependencies, sequencing, and merge-conflict risk. Handles multiple developers as parallel waves, or a single developer as a critical-path sequence.
disable-model-invocation: false
---

# Team Plan

Turn a milestone or issue set into an ordered execution plan.

Establish the developer count first — from `$ARGUMENTS`, the conversation, or Linear assignees. With several developers, produce parallel waves. With one, skip wave assignment and conflict analysis (a single developer cannot collide with themselves) and produce a critical-path sequence: dependency map, recommended order, prerequisites, and the Linear relationships that are missing or wrong.

## Load Rules

Read `~/.claude/rules/question-policy.md` and `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. For full Linear/dependency workflow, read `references/protocol.md`.

## Flow

1. Load milestone/issues and related Linear metadata.
2. For each issue, identify likely code surfaces, dependencies, blockers, and unknowns.
3. Detect conflicts by overlapping files/modules/data migrations.
4. Sequence work into the simplest wave structure that maximizes parallelism without merge collisions — fewest waves and coordination interfaces that satisfy the hard constraints; add structure only when an actual detected conflict requires it, not speculatively.
5. Identify critical path, prerequisites, and coordination points.
6. Update issue relationships only when explicitly requested.

## Output

Return wave plan, assignee-ready work packets, dependencies, conflict risks, and recommended first actions.

