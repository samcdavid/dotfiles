---
model: sonnet
effort: high
name: my-review
runner: skill-my-review
description: "Rigorous local and PR review through a model-pinned mechanical router/assembler. REQUEST_CHANGES needs a verified Critical, High-risk issue; use APPROVE when remaining feedback is Low risk."
when_to_use: "Use when the user asks to review their changes, diff, branch, or a GitHub PR."
---

# Code Review

Use `skill-my-review` for substantive review routing, evidence assembly,
whole-diff synthesis, per-finding verification, and verdict construction. This
wrapper determines the source and authorization context, preserves the
user-facing publication boundary, and renders the runner's structured review
envelope.

## Dispatch

Before dispatch, resolve `ledger_path` from `~/.claude/thoughts/shared/workflows/`; workflow ledgers are retained in Claude Thoughts and never in the worktree. Normalize the request into `{ mode, target, base_ref, artifact_inputs, ledger_path, stage, authority: local_only, publication_authorization: none }` and dispatch it to `skill-my-review`.

- Infer `mode` as capture/promote, PR, branch/range, local, or local issue only from the supplied argument and current context; load the runner's retained shared routing references before resolving ambiguity.
- Match a ledger by its recorded branch first, then its issue/slug context when branch metadata is unavailable. Set `ledger_path: none` only after that Claude Thoughts lookup finds no matching ledger; never search the repository for one.
- For `/my-workflow`, pass the approved plan/base/ledger context and stage number in embedded local mode. The runner returns the compact review envelope plus stable finding keys and prior-ledger matches, so the feedback loop can settle each finding without rehashing it.
- Do not invoke publication from this wrapper unless the user explicitly asks after reviewing the completed result. A runner may never publish a review, reply, resolve a thread, push, create/update a PR, or widen that authorization.

## Present

Return the coverage manifest and findings first with file:line evidence and
concrete fixes, then verdict, questions, residual risk, requirements coverage,
dropped findings, prior resolved/deferred matches, and the compact workflow-stage
envelope when embedded. Use `REQUEST_CHANGES` only for verified findings that
are both `Critical` and `High` risk. Use `APPROVE` when all remaining feedback
is Low risk; use `COMMENT` for Medium/High-risk non-blocking feedback or
unresolved concerns. Do not include raw lens or verifier transcripts.
