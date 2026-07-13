## Phase 6 — Adversarial Verification

Before writing anything to Notion, dispatch the `adversarial-debate` agent (via the `Agent` tool, `subagent_type: "adversarial-debate"`) with:
- The drafted Linear Updates block (Phase 3).
- The drafted Actions and Decisions section (Phase 4).
- The drafted Notes section (Phase 5).
- The full list of Linear ticket IDs, PR links, decisions, people, and meetings cited.

The agent must independently re-verify, not trust the drafts:

- **Status transitions**: every `X → Y` claim must match the actual Linear history for that ticket *today* (agent re-fetches with `get_issue` and inspects today's activity). Tickets claimed as transitioned but actually unchanged in Linear get corrected.
- **Shipped claims**: a ticket claimed as `Done`/`merged` must have `state.type` of `completed` *and* a merged PR linked. A claimed merge timestamp must fall within today's date.
- **PR claims**: every PR link resolves; the PR is actually linked to the cited ticket; open/merge times are today's.
- **Action attribution**: every Action/Decision entry traces to a real artifact gathered in Phase 1 — a PR, a Linear comment, a Notion entry, a calendar event, a Gmail message. No phantom actions.
- **Decision provenance**: each "decided X" entry traces to a real source (a comment, a meeting outcome, a thread). Not fabricated narrative.
- **Drop checks**: nothing from the morning's milestone-review block should leak into the rewritten Notes unless tomorrow-relevant. Anything that *was* an open question this morning and is now resolved should appear in Actions/Decisions, not Notes.

Apply every correction the agent surfaces. Do not write the page while open contradictions remain.
