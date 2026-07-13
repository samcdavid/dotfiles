## Step 4 — Targeted Questions

If the compiled findings include a `### Targeted Questions` block, ask them. The point is to catch things where the situation depends on context only I have.

### After I answer — challenge my answers

Once I respond, spawn the **adversarial-debate** agent to challenge *my* answers. This is a separate pass from the Step 6 finding challenge — the target here is my context, not the assistant's findings.

Pass to the agent:
- The original question + the investigation context that surfaced it (diff, relevant files, the compiled findings)
- My answer

The agent returns a verdict per answer:
- **ACCEPT** — answer holds up; move on
- **PROBE_FURTHER** — answer has gaps, unverified claims, or optimism bias; the agent supplies a follow-up question to ask me
- **FLAG** — answer reveals a real risk (e.g., "we didn't actually check that", "no, that team wasn't told") that should become a finding

Apply the verdicts:
- ACCEPT → record the answer and proceed
- PROBE_FURTHER → ask me the follow-up question; re-run adversarial debate on the new answer (max 2 cycles, then accept or flag)
- FLAG → record as a structured finding (it will get its own adversarial pass in Step 6 along with every other finding)

### When to skip

If the compiled findings include no `### Targeted Questions` block, skip this step entirely.

If I've authorized auto-mode (or said "no questions, just review"), log these as a **Questions** section in the final review output (Step 5) instead of pausing. The post-answer adversarial pass is also skipped in this mode — there are no answers to challenge.
