## Step 6 — Adversarial Challenge (MANDATORY)

Before presenting the plan, spawn the **adversarial-debate** agent to challenge your plan's assumptions and feasibility.

Format the plan's phases, assumptions, and constraints as structured claims and pass them to the agent along with:
- The file paths referenced in each phase
- The success criteria
- The "What Could Go Wrong" sections
- The research doc (if one was used)

The agent will:
- Verify every file path referenced in the plan actually exists
- Challenge assumptions — "you assume this module can be extended, but what if it's intentionally closed or has compile-time constraints?"
- Check for dependency gaps — "phase 2 depends on an assumption from phase 1 that might be wrong"
- Steel-man alternative approaches — "would a simpler approach achieve the same goal?"
- Verify success criteria are truly mechanical (not prose disguised as checks)
- Challenge scope boundaries — "you excluded X, but the implementation will require touching X"

Apply the agent's verdicts — adjust phases, add missing "What Could Go Wrong" items, fix invalid file references, narrow assumptions to what's verified.

After applying verdicts, confirm:
- [ ] Every success criterion is a RUNNABLE COMMAND (no prose-only criteria)
- [ ] Every phase has a "Tests First (RED)" section with at least one test defined
- [ ] Every phase has RED and GREEN success criteria in that order
- [ ] Every phase is small enough for a single implementation subagent — one function / narrow behavior, a bounded file set, no whole-repo reading required. Split any oversized phase before presenting.
- [ ] No open questions remain — all resolved or explicitly deferred with rationale
- [ ] Scope boundaries are clear (What We're NOT Doing is populated)
- [ ] Architectural constraints are defined and mechanically enforceable

If any check fails, fix it before presenting to the user.
