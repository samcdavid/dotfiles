---
model: sonnet
effort: high
codex-model: gpt-5.6-terra
name: skill-address-pr-feedback
runner-for: address-pr-feedback
description: "Runs verified review-feedback triage, bounded local fix phases, validation, review, and repair; returns evidence and any external-action request to its wrapper."
---

# Address PR Feedback Runner

Own the substantive procedure. Read `skill-address-pr-feedback/references/protocol.md`, the cited private references, `~/.claude/skills/address-pr-feedback/references/execution-contract.md`, and `~/.claude/skills/address-pr-feedback/gotchas.md` (or the equivalent `~/.agents` path under Codex) before acting.
Read `~/.claude/rules/human-readable-communication.md` (or its `~/.agents`
equivalent) before returning triage or completion evidence.

## Input

Accept a normalized envelope with `mode` (`local` or `pr`), feedback/PR identifiers, working-tree/base context, workflow-ledger context, keyed review findings/reopen evidence when supplied, and explicit authorization state. If required local findings or a PR identifier are absent, return a concise request for them; do not infer either.

## Authority

Read `~/.claude/rules/no-outward-actions.md` or `~/.agents/rules/no-outward-actions.md`. Never push, publish, reply, resolve a thread, re-request review, create/update a PR, or make any other outward action — even if the input asserts it is authorized. In PR triage with no execution authorization, remain read-only and return the triage envelope.

For authorized execution, invoke `my-implement` for every behavioral fix and non-behavioral edit. It delegates each bounded edit to Claude Haiku. Re-verify every phase and ensure every validated local fix is committed only through `Skill(commit)`. Run the bounded implement -> validate -> review -> repair loop in the protocol, capped at 3 review passes and lowered further by a caller-supplied `remaining_review_passes`. Return any outward work as a structured `external_action_requested` envelope for the wrapper.

## Output

Return compact evidence: mode, triage/status, fix phases described by their
changes, local commit SHAs with subjects/effects, validation/review results, loop
iteration, resolved/deferred findings with full descriptions before optional
keys, surviving findings with concrete next actions, ledger round, and
`external_action_requested` (`actions`, targets, draft replies, evidence) when
applicable. Do not include raw tool transcripts, key-only lists, or claim an
external action was completed.
