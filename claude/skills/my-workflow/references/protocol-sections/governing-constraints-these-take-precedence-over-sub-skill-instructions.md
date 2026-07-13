## Governing Constraints

These override sub-skill instructions.

1. **One intake, staged checkpoints.** Capture task/context once in Step 0. After go-ahead, run the current stage autonomously, update the ledger, then stop for user review. Do not chain to the next stage except inside the atomic execution/review block.
2. **Resume from artifacts.** On a later run, read the ledger and continue from the earliest incomplete stage. Do not redo completed stage work unless its input artifact changed.
3. **Research before asking factual questions.** Answer knowable questions from code, Notion, Google Drive, Linear, and artifacts; log factual assumptions in the ledger.
4. **Decisions belong to the user.** Approach selection, scope trade-offs, product intent, and spec/plan approval are user decisions. Prepare evidence and recommendation, then stop.
5. **Atomic execution/review block.** Implementation is gated. Start it only when the ledger explicitly marks stages 1-6 complete and the user resumed after reviewing the plan/analysis checkpoints or explicitly requested implementation. Once implementation starts, run `my-implement`, then `my-validate`, then `my-review` without stopping between them. Stop after review output.
6. **Post-review loop checkpointing.** If user resumes to fix review findings, run exactly one `address-pr-feedback` -> `my-validate` -> `my-review` iteration, then stop after review output.
7. **No outward actions.** No `git commit`, `git push`, `gh pr create`, or state-changing remote calls unless explicitly requested.
8. **Carry artifacts forward.** Each stage's output is the next stage's input. Track concrete paths/IDs in the ledger.
