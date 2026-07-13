## Step 5 — Adversarial Challenge

Before presenting, spawn the **adversarial-debate** agent to challenge your audit findings. A requirements audit that raises false gaps wastes PM and engineering time — precision matters.

Format all findings (missing requirements, scope creep, edge case gaps, behavior drift, related-issue regression risks) as structured claims and pass them to the agent along with:
- The requirements map from Step 1
- The traceability matrix from Step 2
- The PR diff and full file contents for referenced code
- The Linear ticket and any Notion docs
- The **requirements-tracer** report (Blast Radius, Related Issues, Regression Risks tables)

The agent will:
- Verify that "Missing" requirements aren't actually covered by code you didn't trace — re-read the diff and grep for related identifiers
- Challenge "Excess" code claims — is it truly unrelated, or is it a reasonable supporting change?
- Steel-man scope creep — "you flagged this as unrelated, but the ticket description says 'clean up the surrounding code while you're in there'"
- Verify edge case claims — "you say nil isn't handled, but trace the callers — can this value actually be nil at this point?"
- Check that behavior verification reflects actual user experience, not just code reading — "you say the API response matches the spec, but did you check the serializer?"
- Calibrate severity — distinguish "requirement not implemented" from "requirement implemented slightly differently than one reading of the spec"

Apply the agent's verdicts:
- **KEEP**: gap is real and correctly classified
- **DOWNGRADE**: reclassify (e.g. "Missing" → "Partial" or "Covered with caveat")
- **REVISE**: narrow the claim based on evidence
- **DROP**: remove false gaps — note in "Considered and Dismissed" section

After applying verdicts, confirm:
- [ ] Every "Missing" finding was verified against the full diff (not just file names)
- [ ] "Excess" code claims account for reasonable supporting changes
- [ ] Edge case gaps reflect actual reachable code paths, not theoretical inputs
