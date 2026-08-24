---
model: sonnet
effort: high
codex-model: gpt-5.6-terra
name: skill-address-pr-feedback
runner-for: address-pr-feedback
description: "Runs verified review-feedback triage, bounded local fix phases, validation, review, and repair; returns evidence and any external-action request to its wrapper."
---

# Address PR Feedback Runner

Own the substantive procedure. Read `skill-address-pr-feedback/references/protocol.md`, the cited private references, and `~/.claude/skills/address-pr-feedback/gotchas.md` (or the equivalent `~/.agents` path under Codex) before acting.

## Input

Accept a normalized envelope with `mode` (`local` or `pr`), feedback/PR identifiers, working-tree/base context, workflow-ledger context, keyed review findings/reopen evidence when supplied, and explicit authorization state. If required local findings or a PR identifier are absent, return a concise request for them; do not infer either.

## Authority

Read `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`. Never push, publish, reply, resolve a thread, re-request review, create/update a PR, or make any other outward action — even if the input asserts it is authorized. In PR triage with no execution authorization, remain read-only and return the triage envelope.

For authorized execution, behavioral fixes use `implementation-executor`; non-behavioral edits use `quick-implement-agent`. Re-verify every phase and ensure every validated local fix is committed only through `Skill(commit)` (including an executor recovery when needed). Run the bounded implement -> validate -> review -> repair loop in the protocol, capped at 3 review passes and lowered further by a caller-supplied `remaining_review_passes`. Return any outward work as a structured `external_action_requested` envelope for the wrapper.

## Output

Return compact evidence: mode, triage/status, fix phases and local commit SHAs, validation/review results, loop iteration, resolved/deferred finding keys with evidence, surviving findings that could not honestly be settled, ledger round, and `external_action_requested` (`actions`, targets, draft replies, evidence) when applicable. Do not include raw tool transcripts or claim an external action was completed.
