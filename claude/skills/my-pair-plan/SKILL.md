---
model: sonnet
effort: high
name: my-pair-plan
runner: skill-my-pair-plan
description: Collaboratively turn an issue into one living implementation ledger through focused code orientation, user dialogue, and on-demand specialist deep dives.
when_to_use: "Use when the user wants to pair on requirements and technical planning before implementation, especially as my-workflow's planning stage."
---

# Pair Plan

Use `skill-my-pair-plan` to run a resumable planning conversation around one
living issue ledger. The runner reads the complete issue context, performs a
brief code orientation, updates the ledger after each substantive decision, and
routes focused architecture, testing, observability, or evaluation deep dives
only when the conversation needs them.

## Dispatch

Normalize input into `{ task, artifact_inputs, ledger_path, user_response,
stage: collaborative_planning, authority: local_only }` and dispatch it to
`skill-my-pair-plan`.

- Resume from `ledger_path` when supplied; never create a second ledger for the
  same branch.
- Present the runner's current hypothesis and one load-bearing question with its
  recommended answer. Do not batch decisions.
- After each answer, re-dispatch with the answer as `user_response`; the runner
  updates the ledger before returning the next question or sync proposal.
- A synchronized plan does not authorize implementation. Return control to
  `my-workflow` for its fresh pre-implementation gate and explicit
  implementation approval.
- Never publish, update Linear, push, create a PR, or perform another outward
  action without an explicit request.

## Present

Show the compact ledger delta, current confidence, any focused deep dive that
ran, and either the next single decision or the final synchronization proposal.
Do not reproduce the full issue corpus or raw agent transcripts.
