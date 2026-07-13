## Phase 2 — Enrich Linear

For every Linear issue surfaced in Phase 1 — and every Linear ticket ID mentioned in today's Notion page (Checklist, Actions, Notes) — call `get_issue` and capture:
- Current status and `state.type`.
- Any state transitions visible from today's activity (look at the issue's history / comments / linked PRs to identify what changed *today*, not just current state).
- PR links and their merge/open state.
- Comments authored by me today.
- Blockers added or resolved today.

The output of this phase is a per-ticket change map: morning-state (or last-known prior state) → current state, plus today's work and references.
