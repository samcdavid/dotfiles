## Step 6 — Adversarial Challenge

Before presenting, spawn the **adversarial-debate** agent to challenge your security findings. False positives erode trust in security audits — this step is critical.

Format all findings (critical through low) as structured claims and pass them to the agent along with:
- The file paths and code references for each finding
- The data flow traces from Step 1
- The dependency versions from lockfiles

The agent will:
- Verify every file:line reference against current code
- Challenge exploitability — "you say this is injectable, but is the input actually user-controlled? Trace it."
- Steel-man the existing security posture — "you flagged missing rate limiting, but is there a WAF or reverse proxy handling this?"
- Calibrate severity — "you rated this critical, but the blast radius is a single user's session, not system-wide"
- Verify that suggested fixes don't introduce new vulnerabilities
- Check dependency CVEs against the ACTUAL versions in lockfiles (not just the package name)

Apply the agent's verdicts:
- **KEEP**: finding is exploitable and correctly severity-rated
- **DOWNGRADE**: adjust severity to match actual risk
- **REVISE**: narrow the claim to what's actually demonstrated
- **DROP**: remove false positives — note them in a "Considered and Dismissed" section

After applying verdicts, confirm:
- [ ] Every surviving finding includes a concrete fix
- [ ] Severity classifications reflect actual exploitability, not theoretical worst-case
