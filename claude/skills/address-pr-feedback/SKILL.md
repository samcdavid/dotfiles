---
model: opus
effort: xhigh
name: address-pr-feedback
description: "Address review feedback — GitHub PR comments or local my-review findings — through verified triage, small fix phases, implementation, validation, and evidence-backed replies."
when_to_use: "Use when the user asks to address, respond to, or work through review feedback or review findings."
---

# Address Review Feedback

Work through pending review feedback without blindly accepting or rejecting it. This is a condensed research -> plan -> implement -> validate loop specialized for review feedback.

## Modes

Establish the mode first — it decides the feedback source and whether triage has a confirmation gate.

- **PR mode** (a PR exists): feedback is GitHub comments; triage confirmation is the only gate — it authorizes the rest of the run to finish unattended.
- **Local mode** (`local` in `$ARGUMENTS`, findings passed inline, or no PR): feedback is `my-review`'s findings on the working tree; no gate, no GitHub. Used by `my-workflow`'s automatic fix loop.

Read `references/mode-semantics.md` before acting on either.

## Load Rules

Read these first:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/tdd-phase.md`
- `~/.claude/rules/subagent-contract.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/review-finding-format.md`

PR mode only — skip in local mode:

- `~/.claude/rules/pr-mode-readonly.md`
- `~/.claude/rules/pr-cost-control.md`

Use `~/.agents/rules/` when running through Codex.

Always read `references/pushback-patterns.md` and `references/workflow-ledger-context.md`.

Load targeted references as needed:

- `references/feedback-triage.md` before classifying comments.
- `references/fix-planning.md` before dispatching implementation phases.
- `references/replies-and-publishing.md` before drafting or publishing replies.

## Flow

1. Resolve the mode. PR mode: resolve the PR from `$ARGUMENTS`, current branch, or `gh pr status`. Local mode: take findings from `$ARGUMENTS` or the conversation, and the diff from the working tree against the base branch.
2. Check for a `my-workflow` ledger tied to the current branch (`references/workflow-ledger-context.md`). If found, read its spec/plan before investigating — it supplies requirements, settled decisions, and sibling-overlap context. No match: proceed as below.
3. PR mode only: fetch PR metadata, diff, reviews, inline comments, review bodies, and issue comments using filtered payloads only. Local mode: skip — you already have the findings and the diff.
4. Build a pending-feedback index:
   - reviewer
   - location
   - comment text
   - comment ID and type
   - current addressed/resolved status
5. Fetch linked Linear requirements when present and build a requirements map for regression checks, merging in the ledger's spec/plan requirements from step 2 when a ledger was found.
6. Investigate every pending comment in code context:
   - reproduce or trace the concern
   - verify suggested utilities or patterns
   - check docs for framework/library claims
   - check the ledger for a settled decision or assumption the comment revisits
   - classify with evidence
7. Classify each item:
   - Confirmed Fix
   - Partially Correct
   - Question Requiring Response
   - Valid Deferral
   - Disagree / Push Back
   - Already Addressed
8. Run adversarial challenge on classifications before acting.
9. PR mode: present triage and wait for confirmation (only gate). Local mode: state the triage and proceed — no gate.
10. Plan fixes:
    - behavioral fixes -> `implementation-executor` TDD phases
    - non-behavioral edits -> `quick-implement-agent` direct-edit phases
11. Dispatch one phase at a time, re-verify each result, and apply loop detection. Each phase lands as its own commit — the agent commits after its own validation passes; if it did not and validation passed, commit it yourself via the `commit` skill scoped to that fix's files.
12. Run final validation against tests, requirements map, and reviewer concerns.
13. PR mode: draft evidence-backed replies, push, publish, and resolve threads — no further confirmation. Local mode: skip publishing; report resolution per finding instead.

## Boundaries

- In PR mode, do not check out PR branches or treat local changed files as PR truth. In local mode, the working tree *is* the truth and `pr-mode-readonly.md` does not apply.
- Commit each validated fix locally. In PR mode, triage confirmation (Modes) also authorizes push/reply/resolve. Local mode has no PR.
- Do not implement behavioral fixes in the main context; dispatch the executor.
- Do not defer fixes under roughly 20 lines unless there is a real scope or product reason.
- Do not push back without specific code, test, docs, or requirement evidence.

## Output

Return pending-feedback triage, fixes with commit SHAs, validation results, unresolved items, and in PR mode what was pushed, posted, and resolved.
