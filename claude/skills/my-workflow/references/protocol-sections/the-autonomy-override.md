## Autonomy Override

For the selected stage, invoke the stage skill with established context: task plus concrete artifact paths/IDs from the ledger. Then follow that skill with these adjustments:

- **Intake prompts stay internal.** If the stage skill asks for topic/context, provide it from the ledger and continue within the stage.
- **Factual gates are researched.** If the stage asks to confirm how code behaves, what requirements say, or whether wiring exists, verify through code/docs/tickets/artifacts and log the factual assumption.
- **Decision gates stop.** If the stage reaches approach choice, scope trade-off, product intent, or spec/plan approval, prepare options and recommendation, then stop for the user.
- **Question batches are filtered.** For `my-spec`, `my-plan`, and `my-clarify`, answer factual questions through the Blocking-Question Protocol and surface only real decisions.
- **Plan approval is user-owned.** The plan may be written before approval, but implementation cannot start until the user resumes after approving it and the ledger marks stages 1-6 complete.
- **Stage boundary is hard.** When the selected stage completes, checkpoint and stop unless currently inside `my-implement -> my-validate -> my-review`.
- **Do not double-spawn.** Only one stage skill runs at a time.
