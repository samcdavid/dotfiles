---
effort: xhigh
name: team-plan
runner: skill-team-plan
description: Draft MVP-first Linear milestones and very small, low-overlap issues for quick parallel implementation and review.
disable-model-invocation: false
---

# Team Plan

Use `skill-team-plan` for the substantive project-discovery and issue-design procedure. This wrapper owns request normalization, read-only Linear context, the approval boundary, and any approved Linear mutations; the runner produces the evidence-backed planning package and draft manifest.

Every planned milestone must end in a stakeholder-demoable MVP slice. Every implementation issue targets a single, independently reviewable behavior with only a few small changes and a start-to-finished-review time of 30 minutes or less. This is a sizing target, not a reason to invent administrative work or split a coherent behavior across tickets. Preserve safe parallelism through clear boundaries and explicit prerequisites rather than broad tickets.

## Dispatch

Read `~/.claude/rules/question-policy.md` and `~/.claude/rules/context-checkpoint.md` when available, or their `~/.agents/rules/` equivalents under Codex. Read `references/protocol.md` for the complete workflow.

1. Resolve the request from `$ARGUMENTS` and conversation. For a supplied project, milestone, or issue URL, collect the bounded, read-only Linear inventory needed to plan it. Do not write to Linear.
2. Dispatch `skill-team-plan` with `{ task, linear_context, artifact_inputs, authority: local_only }`. The runner may create local artifacts and call the required spec, research, architecture, and adversarial runners; it must return a draft only.
3. Present the runner's requirements/gap evidence, MVP milestones, micro-issue drafts, coordination plan, and exact Linear manifest. Ask for explicit approval before any Linear create, update, comment, relationship, or status change.
4. Only after approval, re-query the affected Linear records, apply exactly the approved manifest, and verify the resulting records. If current state differs materially, stop and request direction rather than widening the change.

## Output

Return the requirements brief, evidence-backed gap map, job stories, micro-issue drafts, migration plan where applicable, milestone demo definitions and waves, dependency/conflict and coordination analysis, and the exact Linear changes awaiting approval.
