---
model: opus
effort: xhigh
name: address-pr-feedback
description: "Address review feedback — GitHub PR comments or local my-review findings — through verified triage, small fix phases, implementation, validation, and evidence-backed replies."
when_to_use: "Use when the user asks to address, respond to, or work through review feedback or review findings."
---

# Address Review Feedback

Work through pending review feedback without blindly accepting or rejecting it — a condensed research -> plan -> implement -> validate loop.

## Modes

Establish the mode first — it decides the feedback source and whether triage gates.

- **PR mode** (a PR exists): feedback is GitHub comments; triage confirmation is the only gate, authorizing the rest of the run unattended.
- **Local mode** (`local` in `$ARGUMENTS`, findings passed inline, or no PR): feedback is `my-review`'s findings on the working tree; no gate. Used by `my-workflow`'s fix loop.

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

Load as needed: `references/feedback-triage.md` before classifying, `references/fix-planning.md` before dispatching phases, `references/replies-and-publishing.md` before replies, `references/self-audit-checklist.md` before self-audit.

## Flow

1. Resolve the mode. PR mode: find the PR via `$ARGUMENTS`, current branch, or `gh pr status`. Local mode: take findings from `$ARGUMENTS` or the conversation, diffing the working tree against the base branch.
2. Check for a `my-workflow` ledger on the current branch (`references/workflow-ledger-context.md`). If found, read its spec/plan first — requirements, settled decisions, sibling overlap — and append this run's round record to it at step 14. No match: skip step 14.
3. PR mode only: fetch PR metadata, diff, reviews, inline comments, review bodies, and issue comments with filtered payloads. Local mode: skip — you have the findings and the diff already.
4. Build a pending-feedback index: reviewer, location, comment text, comment ID and type, addressed/resolved status.
5. Fetch linked Linear requirements and build a requirements map for regression checks, merged with the ledger's spec/plan requirements from step 2.
6. Investigate every pending comment in code context — trace the concern, verify suggested utilities and patterns, check docs for framework claims, check the ledger for a settled decision it revisits.
7. Classify each with evidence: Confirmed Fix, Partially Correct, Question Requiring Response, Valid Deferral, Disagree / Push Back, Already Addressed.
8. Run adversarial challenge on classifications before acting.
9. PR mode: present triage, wait for confirmation (only gate). Local mode: state it and proceed.
10. Plan fixes: behavioral -> `implementation-executor` TDD phases; non-behavioral -> `quick-implement-agent` direct-edit phases.
11. Dispatch one phase at a time, re-verify each result, and apply loop detection. Each phase lands as its own commit — the agent commits once its validation passes; otherwise use the `commit` skill, scoped to that fix's files.
12. Validate against tests, requirements map, and reviewer concerns.
13. PR mode: draft evidence-backed replies, then push, publish, resolve threads, and re-request review — no further confirmation. Local mode: report resolution per finding, publish nothing.
14. If step 2 found a ledger, append this run's round record to it: verdict table with commit SHAs, lessons worth carrying, deferrals with reasons, validation results.

## Boundaries

- In PR mode, never check out PR branches or treat local files as PR truth. In local mode the working tree *is* truth; `pr-mode-readonly.md` does not apply.
- Commit each validated fix locally. In PR mode, triage confirmation (Modes) also authorizes push/reply/resolve/re-request; local mode has no PR.
- Do not implement behavioral fixes in the main context; dispatch the executor.
- Do not defer low-effort fixes (mechanical, single-location, no design decision; ~20 lines is a proxy, not the test) without a real scope reason. Fix them here, not via a ticket.
- Do not push back without specific code, test, docs, or requirement evidence.
- Do not rewrite existing ledger content or create a ledger that doesn't exist. Append the round record only; the rest stays `my-workflow`'s.

## Output

Return pending-feedback triage, fixes with commit SHAs, validation results, unresolved items, the ledger round appended, and in PR mode what was pushed, posted, resolved, and re-requested.
