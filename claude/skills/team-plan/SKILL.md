---
model: opus
name: team-plan
description: Plan parallel milestone work for multiple developers by analyzing issue surfaces, dependencies, sequencing, and merge-conflict risk.
---

# Team Plan

Turn a milestone or issue set into parallelizable work waves.

## Load Rules

Read `~/.claude/rules/question-policy.md` and `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. For full Linear/dependency workflow, read `references/protocol-index.md`.

## Flow

1. Load milestone/issues and related Linear metadata.
2. For each issue, identify likely code surfaces, dependencies, blockers, and unknowns.
3. Detect conflicts by overlapping files/modules/data migrations.
4. Sequence work into waves that maximize parallelism without merge collisions.
5. Identify critical path, prerequisites, and coordination points.
6. Update issue relationships only when explicitly requested.

## Output

Return wave plan, assignee-ready work packets, dependencies, conflict risks, and recommended first actions.

