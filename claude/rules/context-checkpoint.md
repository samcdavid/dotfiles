# Context Checkpoint

At stage boundaries:

1. Write durable state to the expected artifact or ledger.
2. Carry forward only task, current stage, artifact paths, user decisions, factual assumptions, commands run, and next action.
3. Drop raw logs, raw diffs, subagent transcripts, and exploratory notes unless needed for the current step.
4. If resuming, read the durable artifact first and continue from the latest incomplete stage.

