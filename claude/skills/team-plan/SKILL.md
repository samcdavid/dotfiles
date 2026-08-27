---
effort: xhigh
name: team-plan
runner: skill-team-plan
description: Draft demoable, parallel Linear milestones with small TDD issues and explicit blocking relationships.
disable-model-invocation: false
---

# Team Plan

Use `skill-team-plan` for the substantive project-discovery and issue-design procedure. This wrapper owns request normalization, read-only Linear context, the approval boundary, and any approved Linear mutations; the runner produces the evidence-backed planning package and draft manifest.

Every planned milestone must produce a concrete team-demoable outcome, contain
no more than 15 issues, and belong to a delivery graph that maximizes safe
parallel work across milestones as well as within them. Every implementation
issue targets one independently reviewable behavior deliverable in 3–5 small
commits; each commit follows RED → GREEN → VALIDATE → commit. Do not invent
filler commits or administrative issues to hit those bounds: combine undersized
work only when it preserves one coherent behavior, and split work that needs
more than five meaningful cycles.

## Dispatch

Read `~/.claude/rules/question-policy.md` and `~/.claude/rules/context-checkpoint.md` when available, or their `~/.agents/rules/` equivalents under Codex. Read `references/protocol.md` for the complete workflow.

1. Resolve the request from `$ARGUMENTS` and conversation. For a supplied project, milestone, or issue URL, collect the bounded, read-only Linear inventory needed to plan it. Do not write to Linear.
2. Dispatch `skill-team-plan` with `{ task, linear_context, artifact_inputs, authority: local_only }`. The runner may create local artifacts and call the required spec, research, architecture, and adversarial runners; it must return a draft only.
3. Present the runner's requirements/gap evidence, demoable milestones,
   3–5-commit issue drafts, milestone/issue dependency graphs, coordination plan,
   and exact Linear manifest. Ask for explicit approval before any Linear create,
   update, comment, relationship, or status change.
4. Only after approval, re-query the affected Linear records, apply exactly the
   approved manifest, and verify the resulting records and every blocker edge.
   Preserve valid existing blocker relationships unless their removal was
   explicitly approved. If current state differs materially, stop and request
   direction rather than widening the change.

## Output

Return the requirements brief, evidence-backed gap map, job stories, 3–5-commit
issue drafts, migration plan where applicable, milestone demo definitions and
parallel lanes, complete issue/milestone dependency and conflict analysis, and
the exact Linear changes—including blocker relationships—awaiting approval.
