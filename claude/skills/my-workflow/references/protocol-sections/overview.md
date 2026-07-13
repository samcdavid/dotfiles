---
model: opus
name: my-workflow
description: Run the delivery pipeline with review checkpoints: my-research -> my-spec -> my-clarify -> my-plan -> my-observe -> my-analyze -> gated atomic my-implement -> my-validate -> my-review. Resume from ledger after context clearing.
disable-model-invocation: true
---

# My Workflow

Orchestrate the delivery pipeline as resumable stage work. The task is established once at intake, artifacts carry context between stages, and the workflow ledger is the resume source of truth.

Each major stage stops for user review after producing its artifact. The user can clear context and invoke `my-workflow` again; the next run reads the ledger and continues from the earliest incomplete stage.

The exception is the atomic execution/review block: once gated implementation starts, run `my-implement`, then `my-validate`, then `my-review` without stopping between them. Stop after the review output. Implementation cannot start from a new workflow or loose artifacts; it requires completed ledger status for all prior stages.

Factual questions are still handled autonomously through research. Genuine decisions remain user-owned.
