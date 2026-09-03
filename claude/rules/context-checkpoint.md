# Context Checkpoint

At stage boundaries:

1. Write durable state to the expected artifact or ledger.
2. Carry forward only task, current stage, artifact paths, user decisions, factual assumptions, commands run, and next action.
3. Drop raw logs, raw diffs, subagent transcripts, and exploratory notes unless needed for the current step.
4. If resuming, read the durable artifact first and continue from the latest incomplete stage.

## Context budget

Context checkpoints are mandatory, not merely a presentation convention. Before
the active coordinator reaches roughly 80k tokens of retained context (or when
the runtime warns that the context window is becoming constrained), write the
handoff, end the current run, and resume in a fresh context from that durable
state. Do not carry a conversation past that point merely because a stage is
still in progress.

For a multi-stage repair or review, also checkpoint after every completed
combined validation gate and review pass. A handoff must identify the current
HEAD/base or evidence fingerprint, settled triage decisions, commits, commands
and final statuses, artifact paths, and exactly one next action. It must not
embed a full diff, passing logs, or raw subagent output.
