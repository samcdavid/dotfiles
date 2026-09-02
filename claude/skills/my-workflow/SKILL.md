---
model: sonnet
effort: high
name: my-workflow
skill-only: coordinator
description: "Pair with the user in one living issue ledger, run a fresh pre-implementation gate, then complete the existing implementation and review loops."
disable-model-invocation: false
---

# My Workflow

Run delivery as a resumable collaborative-planning phase followed by the
existing implementation and review phases. This skill-only coordinator has no
runner.

`my-pair-plan` owns issue intake, brief code orientation, conversation,
on-demand specialist deep dives, and the single living workflow ledger. It
returns across as many user turns as needed. Once the user synchronizes the
ledger, run the fresh pre-implementation gate; only then request explicit
implementation authorization and dispatch `my-implement`, one whole-plan
`my-validate` gate after implementation completes, then `implement-review`.

Never infer implementation permission. Migration work always uses this full
flow and the safety gate in `references/migration-safety.md`. `my-quick` remains
an explicit, ledgered alternative for qualifying small work.

## Load Rules

Read first:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/no-outward-actions.md`
- `~/.claude/rules/loop-detection.md`
- `~/.claude/rules/model-escalation.md`
- `~/.claude/rules/human-readable-communication.md`
- `references/stage-routing.md`

Use `~/.agents/rules/` under Codex. Load `references/protocol.md` for the full
flow, `references/checkpoint-policy.md` before a stop,
`references/cross-workflow-coordination.md` for Linear context and refreshes,
and `references/migration-safety.md` whenever persisted schema/data is involved.

## Pipeline

1. Establish or resume the one branch-matched workflow ledger and choose
   `my-workflow` versus an explicit `my-quick` handoff.
2. Dispatch `my-pair-plan` in collaborative-planning mode. Present one
   load-bearing decision at a time and re-dispatch each answer until the living
   ledger is explicitly synchronized.
3. Run the pre-implementation gate against that synchronized plan version:
   refresh issue/sibling context, run the ledger consistency/traceability audit,
   and check current sibling overlap.
4. Stop for explicit implementation authorization.
5. Dispatch `my-implement` with the ledger as the approved plan and test
   strategy. Let it complete every phase and its holistic test gate.
6. Dispatch `my-validate` once against the completed plan and implementation
   evidence. Stop if its whole-plan validation cannot pass.
7. Dispatch `implement-review` only after that validation passes; preserve its
   bounded review/repair loop unchanged.

Update the ledger after every planning turn, gate, implementation phase result,
validation result, and review outcome. Local commits are expected from the existing execution
skills; never push, publish, create/update a PR, deploy, or mutate remote state
without an explicit request.

## Output

During planning, return the compact ledger delta and next single decision. At
each decision or question, show the smallest relevant current-code block with
file/line context, or a clearly labeled proposed-code sketch when the surface
does not exist yet. At sync, return the complete planning surface. At the
pre-implementation stop, return gate evidence and request implementation
authorization. At completion,
return implementation, whole-plan validation, and review evidence from the ledger. Do not reproduce raw
issue payloads, agent transcripts, or superseded standalone planning artifacts.
Lead with the actual requirements, decisions, changes, and findings. Never make
the user decode ledger IDs, phase numbers, finding keys, or workflow states.
