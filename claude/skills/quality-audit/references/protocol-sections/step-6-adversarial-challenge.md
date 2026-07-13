## Step 6 — Adversarial Challenge

Before presenting, spawn the **adversarial-debate** agent to challenge your quality findings. False gaps waste engineering effort writing unnecessary tests — precision matters.

Format all findings as structured claims and pass them to the agent along with:
- The test files and production files for each finding
- The coverage gap claims with specific branches/paths identified
- The fidelity claims with specific test names and assertion lines

The agent will:
- Verify every file:line reference against current code
- Challenge coverage gaps — "you say this branch is untested, but did you check the integration test at test_file:line that exercises this path?"
- Steel-man existing tests — "you say this assertion is vacuous, but the factory setup guarantees specific values — the shape check IS sufficient here"
- Verify flakiness claims — "you flagged this as time-dependent, but the test uses frozen time via `DateTime.utc_now()` mock"
- Check mock fidelity claims against actual interfaces
- Calibrate severity — distinguish "this gap will let a real bug through" from "this could theoretically be more thorough"

Apply the agent's verdicts:
- **KEEP**: gap is real and risk-justified
- **DOWNGRADE**: adjust severity based on actual risk
- **REVISE**: narrow the claim to what's demonstrated
- **DROP**: remove false gaps — note in "Considered and Dismissed" section

After applying verdicts, confirm:
- [ ] Every surviving coverage gap identifies a realistic bug class it would miss
- [ ] Fidelity claims are verified against actual test code, not assumptions
- [ ] Recommendations are proportional to the risk of the code area
