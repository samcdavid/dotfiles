---
model: opus
name: address-pr-feedback
description: Address pending PR review feedback through verified triage, small fix phases, implementation, validation, and evidence-backed replies. Manual invocation only.
disable-model-invocation: true
---

# Address PR Feedback

Work through pending PR review feedback without blindly accepting or rejecting comments. This is a condensed research -> plan -> implement -> validate loop specialized for review feedback.

## Load Rules

Read these first:

- `~/.claude/rules/pr-mode-readonly.md`
- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/tdd-phase.md`
- `~/.claude/rules/subagent-contract.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/review-finding-format.md`
- `~/.claude/rules/pr-cost-control.md`

Use `~/.agents/rules/` when running through Codex.

Always read `references/pushback-patterns.md`.

Load targeted references as needed:

- `references/feedback-triage.md` before classifying comments.
- `references/fix-planning.md` before dispatching implementation phases.
- `references/replies-and-publishing.md` before drafting or publishing replies.

## Flow

1. Resolve the PR from `$ARGUMENTS`, current branch, or `gh pr status`.
2. Fetch PR metadata, diff, reviews, inline comments, review bodies, and issue comments using filtered payloads only.
3. Build a pending-feedback index:
   - reviewer
   - location
   - comment text
   - comment ID and type
   - current addressed/resolved status
4. Fetch linked Linear requirements when present and build a requirements map for regression checks.
5. Investigate every pending comment in code context:
   - reproduce or trace the concern
   - verify suggested utilities or patterns
   - check docs for framework/library claims
   - classify with evidence
6. Classify each item:
   - Confirmed Fix
   - Partially Correct
   - Question Requiring Response
   - Valid Deferral
   - Disagree / Push Back
   - Already Addressed
7. Run adversarial challenge on classifications before acting.
8. Present triage and wait for user confirmation.
9. Plan fixes:
   - behavioral fixes -> `implementation-executor` TDD phases
   - non-behavioral edits -> `quick-implement-agent` direct-edit phases
10. Dispatch one phase at a time, re-verify each result, and apply loop detection.
11. Run final validation against tests, requirements map, and reviewer concerns.
12. Draft evidence-backed replies. Do not publish unless explicitly asked.

## Boundaries

- Do not check out PR branches or treat local changed files as PR truth.
- Do not commit, push, publish replies, or mark threads resolved unless explicitly asked.
- Do not implement behavioral fixes in the main context; dispatch the executor.
- Do not defer fixes under roughly 20 lines unless there is a real scope or product reason.
- Do not push back without specific code, test, docs, or requirement evidence.

## Output

Return pending-feedback triage, fixes completed, validation commands/results, unresolved items, and draft replies grouped by comment.
