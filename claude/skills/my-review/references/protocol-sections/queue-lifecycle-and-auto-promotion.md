## Queue lifecycle and auto-promotion

The queue at `references/learned-misses.md` is the single source of truth for patterns the skill is learning. Lifecycle:

1. **Capture** — entry appended with `status: pending`. Shape is the key; matching new captures against existing Shapes appends Evidence rather than creating duplicates.
2. **Accumulate** — Evidence accrues across reviews. Both `type: caught` and `type: missed` (and `type: noted` from `capture` mode) count toward the threshold.
3. **Auto-promote** — when `len(evidence) >= 3`:
   - Draft promotion wording (from the entry's `Proposed promotion: wording` field if set; otherwise generated from Shape + Evidence summary).
   - Pick the target file (from `Proposed promotion: target` if set; otherwise inferred — see below).
   - Write to the target file under the appropriate section.
   - Mark entry `status: promoted (<today's date>)` and move it to `## Promoted`. Entry is preserved for audit.
4. **Surface** — at the next `/my-review` invocation, Step 2's triage block reports the auto-promotion.

### When does the auto-promote check run?

At the top of every `/my-review` invocation (after mode detection, before Step 1). Scan `## Pending` for entries whose Evidence length has crossed threshold; auto-promote them before producing the triage block.

### Target inference (when `Proposed promotion: target` is absent)

- Shape describes "review should affirmatively check for X" in a lens-specific way → that lens's skill `SKILL.md` (e.g. `~/.claude/skills/security-audit/SKILL.md`).
- Shape describes a cross-cutting review category → `references/general-checklist.md` under the appropriate section.
- Shape describes a cross-service pattern → `references/cross-service-contracts.md`.
- Shape describes "skill itself does the wrong thing" → `gotchas.md`, using the existing **Category / Context / Wrong / Right / Why / Source** structure.
- Ambiguous → transition to `status: ready` (not auto-promoted) and surface loudly in next `/my-review` triage block for me to resolve via `/my-review promote`.

### Threshold

Currently **3**. Tune by editing this section. Lower = snappier learning, more noise; higher = more conservative.

### Manual overrides

- `/my-review promote` — promote pending entries early or discard one-offs.
- `git revert` — undo an auto-promotion entirely. The queue entry stays as `promoted`; if you don't also discard it via `/my-review promote`, additional Evidence accruing later won't re-trigger auto-promote.
