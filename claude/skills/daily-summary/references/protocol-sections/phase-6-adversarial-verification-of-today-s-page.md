## Phase 6 — Adversarial Verification of Today's Page

After Phase 5 has drafted the checklist and milestone-review block (but **before** they are written to Notion via `notion-create-pages` / `notion-update-page`), dispatch the `adversarial-debate` agent (via the `Agent` tool, `subagent_type: "adversarial-debate"`) with the full drafted page content and the list of every Linear ticket ID, project, milestone, sender, and meeting it cites. The agent must independently re-verify, not trust the draft:

- **Closed-work leakage**: re-fetch each checklist ticket with `get_issue`; flag any with `state.type` in `{completed, canceled}` (defense-in-depth on top of Phase 5 step 1).
- **Priority/assignee claims**: every "Urgent — mine" / "Urgent — grabbable" / "High — unassigned bottleneck" ticket must currently match that priority and assignee state in Linear.
- **Milestone scope**: every ticket cited in the Notes block must belong to the named active milestone of the named project.
- **Lead/membership claim**: if the milestone-review names the user as project lead, verify against the actual project record.
- **Email/meeting trace**: every email-sourced checklist row must trace back to a real Gmail message from Phase 1; every meeting row to a real calendar event from Phase 1.
- **Recommended next-work order**: each recommendation's stated reason ("blocks X", "first sub-task of Y") must hold up against the cited relations.

Apply every correction the agent surfaces. Do not write the page while open contradictions remain. Once clean, write the page.
