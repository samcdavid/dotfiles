## Subcommands — `capture`, `promote`

### `/my-review capture`

Direct, source-agnostic entry into the pattern queue. Use when a pattern surfaces outside the natural prompts in Step 6 and Step 8 — a bug report, a post-mortem, a Slack thread, a hunch.

Flow:
1. Ask: what pattern are we capturing? Collect Shape (one or two sentences, the *general* pattern), Trigger signals, and the source `ref`.
2. Check `references/learned-misses.md` for an existing matching Shape. If found, append Evidence (`type: noted`, today's date, the source `ref`) to the existing entry.
3. Otherwise, draft the entry and confirm with me before writing under `## Pending` with `status: pending`.

Default Evidence type is `noted` (the user is calling it out — neither a clean catch nor a clean miss).

Do **not** run any review flow in this mode. Just capture and exit.

### `/my-review promote`

Walk the pending queue one entry at a time (use the `walk-through` skill). For each entry with `status: pending` or `status: ready`:

1. Show the Shape, Trigger signals, and Evidence summary.
2. Reaffirm the Shape — is the generalization right, too narrow, or too broad? Offer to rewrite.
3. Confirm the **target file**:
   - Lens reference (e.g., `references/cross-service-contracts.md`) for a positive check ("review should affirmatively check for X").
   - `references/general-checklist.md` for a general-review category addition.
   - The relevant lens skill's `SKILL.md` (e.g. `~/.claude/skills/security-audit/SKILL.md`) when the pattern belongs to a specific lens.
   - `gotchas.md` for a failure-mode lesson ("skill itself does the wrong thing").
4. Confirm the exact wording — show what will be written, let me edit.
5. On approval: write to target file under the appropriate section, mark entry `status: promoted (<today's date>)`, move entry to `## Promoted` section.
6. On reject: mark `status: discarded (<today's date>, <one-line reason>)`, move to `## Discarded`.

Do **not** run any review flow in this mode.
