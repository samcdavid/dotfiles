## Step 2 — Broad Codebase Research

Before diving into individual issues, map the full surface area of the milestone in one pass. Spawn in parallel:
- **codebase-locator**: find all files relevant to the surfaces mentioned across all issues
- **codebase-analyzer**: understand the architecture — how affected modules connect, key interfaces, data models, ownership boundaries
- **codebase-pattern-finder**: find existing patterns for the types of changes these issues require

Synthesize and save to `~/.claude/thoughts/shared/research/NNN_milestone_{milestone_slug}.md`.

Run an **adversarial-debate** agent on any architectural assumptions before proceeding — apply verdicts.
