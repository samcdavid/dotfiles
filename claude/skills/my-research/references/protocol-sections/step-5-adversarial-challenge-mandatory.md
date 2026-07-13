## Step 5 — Adversarial Challenge (MANDATORY)

Before finalizing, spawn the **adversarial-debate** agent to challenge your findings.

Format your detailed findings as structured claims and pass them to the agent along with:
- The file paths and code references supporting each finding
- Any architectural claims or interpretations
- The original research question

The agent will:
- Verify every file path and code snippet against current code
- Challenge interpretations — "you found X calls Y, but does that mean what you think it means?"
- Check for contradictions between findings
- Steel-man alternative interpretations of the code
- Flag conclusions that go beyond what the evidence supports

Apply the agent's verdicts:
- **KEEP**: finding is well-grounded, present as-is
- **REVISE**: adjust the claim to match what the evidence actually shows
- **DROP**: remove findings that couldn't be verified or were based on misread code

After applying verdicts, confirm:
- [ ] The research question is fully addressed
- [ ] Open questions are explicitly noted (not silently skipped)
- [ ] No contradictory findings remain unresolved

Do NOT present unverified claims.
