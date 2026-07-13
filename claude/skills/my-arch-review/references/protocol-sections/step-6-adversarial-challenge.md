## Step 6 — Adversarial Challenge

Before presenting, spawn the **adversarial-debate** agent to challenge your architectural assessments.

Format your concerns, deviation judgments, and coupling/cohesion claims as structured findings and pass them to the agent along with:
- The file paths and dependency traces supporting each claim
- Your understanding of the established conventions
- The diff or artifact being reviewed

The agent will:
- Verify that claimed conventions actually exist in the codebase (not assumed from other projects)
- Steel-man architectural choices — "you say this coupling is bad, but what if it's intentional for performance or simplicity?"
- Challenge deviation judgments — is something flagged as "undesirable" actually the established pattern?
- Check for contradictions — praising a pattern in one place but flagging it in another
- Verify that dependency direction claims match actual import graphs

Apply the agent's verdicts, then confirm:
- [ ] Suggestions are concrete and respect the existing architecture's intent
- [ ] Desirable vs. undesirable deviations are clearly distinguished with rationale
