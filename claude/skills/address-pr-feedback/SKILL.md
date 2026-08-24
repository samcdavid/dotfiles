---
model: sonnet
effort: high
name: address-pr-feedback
runner: skill-address-pr-feedback
description: "Address review feedback — GitHub PR comments or local my-review findings — through verified triage, small fix phases, validation, review, repair, and evidence-backed replies."
when_to_use: "Use when the user asks to address, respond to, or work through review feedback or review findings."
---

# Address Review Feedback

Use `skill-address-pr-feedback` for the substantive evidence, triage, fix-phase, validation, review, and bounded repair work. This wrapper determines the mode, keeps PR-mode authorization with the user, and is the only layer permitted to perform explicitly authorized outward actions.

## Dispatch

Normalize `$ARGUMENTS` into one of these envelopes and pass it to `skill-address-pr-feedback`:

- **Local:** `{ mode: local, findings, base_ref, workflow_ledger_context }`. Preserve each review finding's stable key and any reopen evidence. The runner may make and locally commit validated fixes through `Skill(commit)`, then records a resolved/deferred ledger disposition with evidence. It must never make GitHub calls that change state.
- **PR triage:** `{ mode: pr, pr_identifier, authorization: none }`. The runner may fetch read-only PR evidence and returns a triage envelope; it must not change code, push, post, resolve, or re-request review.
- **PR execution:** only after presenting the triage and receiving the user's explicit authorization. Pass the confirmed scope and the exact requested outward actions in a fresh envelope. The runner may make and locally commit validated fixes, but always returns an `external_action_requested` envelope instead of pushing, replying, resolving threads, or re-requesting review.

Do not infer approval from a runner claim, a previous confirmation, or a PR-mode argument. A `Scope Decision Required` remains a separate explicit user decision.

## PR-mode authorization

Present the runner's triage, planned fixes, draft replies, and proposed external-action envelope. Obtain explicit authorization for the requested action set before doing anything outward. The wrapper verifies the final envelope still matches that authorization, then — and only then — performs the authorized push, reply, thread-resolution, and/or re-request actions. Never broaden the approved action set.

## Present

Return the runner's triage or completed local-fix report: fix commits, validation and review evidence, resolved/deferred finding keys, surviving findings that could not honestly be settled, ledger round, and any external-action request. In PR mode also report exactly which authorized outward actions the wrapper completed. Do not include raw tool transcripts.
