## Step 3 — Scope Analysis

### Scope Creep Detection
For every code change that doesn't trace to a requirement:
- Is it a necessary supporting change? (refactoring for the feature, test infrastructure, config)
- Is it a tangential improvement bundled into the PR?
- Is it an unrelated change that should be a separate PR?

### Requirement Drift
Compare the implementation against the original spec:
- Does the implementation interpret any requirement differently than intended?
- Are there implicit assumptions in the code that aren't in the spec?
- Has the scope expanded beyond what was specified? (more fields, more endpoints, more behavior)
- Has the scope contracted? (fewer fields, simplified behavior, deferred functionality)

### User-Facing Behavior Changes
Identify every change visible to end users:
- New UI elements, modified copy, changed layouts
- New or modified API responses
- Changed email/notification content
- Modified permissions or access levels
- Changed default values or behavior

For each, verify it was intentional (traces to a requirement) and not a side effect.

### Related-Issue Regression
Take the **requirements-tracer**'s `Related Issues` and `Regression Risks` tables. For each `At-risk` related issue:
- Confirm the surface and the call chain from the tracer are real (spot-check `file:line` against the diff or `gh api` content).
- Classify the regression as: `Likely-breakage` / `Behavior-shift-unverified` / `Cosmetic-only`.
- For `Likely-breakage` and `Behavior-shift-unverified`, surface as a finding in Step 6's "Missing or Incomplete Requirements" section (framed as "shipped requirement RN from issue X at risk").

`Verified-still-working` and `Unaffected` verdicts from the tracer are not reported as findings — list them in Step 6's "Considered and Dismissed" with one-line notes.
