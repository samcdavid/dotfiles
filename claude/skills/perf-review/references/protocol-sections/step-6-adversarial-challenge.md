## Step 6 — Adversarial Challenge

Before presenting, spawn the **adversarial-debate** agent to challenge your performance findings. False positives waste engineering effort on premature optimization — this step is critical.

Format all findings as structured claims and pass them to the agent along with:
- The file paths and code references for each finding
- The query traces from Step 2
- The resource consumption analysis from Step 3

The agent will:
- Verify every file:line reference against current code
- Challenge severity — "you flagged this as an N+1, but is this loop ever called with more than 5 items? Check the callers."
- Steel-man the current approach — "you suggest adding a cache, but this endpoint is called 10 times a day — is the complexity worth it?"
- Verify that query analysis reflects actual schema and indexes (not assumed)
- Check whether suggested optimizations would actually improve the bottleneck or just shift it
- Calibrate impact — distinguish "will page oncall under load" from "could be marginally faster"

Apply the agent's verdicts:
- **KEEP**: finding is real and impact-justified
- **DOWNGRADE**: adjust severity to match actual scale/frequency
- **REVISE**: narrow the claim to what's actually demonstrated
- **DROP**: remove premature optimizations or false positives — note in "Considered and Dismissed" section

After applying verdicts, confirm:
- [ ] Every surviving finding includes a concrete fix with expected impact
- [ ] Severity reflects actual load and scale, not theoretical worst-case
- [ ] No premature optimizations recommended (cost of change > cost of problem)
