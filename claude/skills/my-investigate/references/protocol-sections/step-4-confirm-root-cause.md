## Step 4 — Confirm root cause

Based on ranked hypotheses + any user answers:

1. **If there's a clear top hypothesis** (high confidence, evidence in its favor, no strong counter-evidence): present it as the likely root cause and ask the user to confirm or redirect. Do not ask the user to "pick" a hypothesis.
2. **If evidence is genuinely split**: surface the top two and ask which to pursue first.
3. Re-invoke the agent with additional context if more investigation is needed. Escalate to a human investigator when the investigation is going in circles — not after a fixed number of rounds.

Once root cause is confirmed:
- **What broke?** specific code path, configuration, data issue, infrastructure failure
- **Why did it break?** what changed — deploy, data, traffic, dependency
- **Why wasn't it caught?** missing test, missing monitor, edge case not considered
