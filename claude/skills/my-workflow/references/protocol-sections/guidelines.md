## Guidelines

- Run one checkpointed stage per invocation, except for the atomic execution/review block.
- Research factual questions before asking; never ask what code, docs, tickets, or artifacts can answer.
- Do not decide judgment calls the user reserves.
- Keep the ledger current; it is the resume contract after context clearing.
- If routing to `my-quick`, note that upfront in the workflow ledger before handoff.
- Every checkpoint should make the next command obvious.
- Skipping a stage requires a current artifact and completed ledger status.
- Never start implementation from artifact inference alone; require the stage-routing implementation gate.
- Surface assumptions loudly.
- A blocker stops the pipeline; do not work around it silently.
