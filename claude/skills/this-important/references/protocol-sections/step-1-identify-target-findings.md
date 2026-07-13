## Step 1 — Identify Target Findings

Determine what to challenge:
- If `$ARGUMENTS` contains structured findings (passed in by another skill), use those.
- If `$ARGUMENTS` names a specific area or topic, focus on findings in that area from the recent conversation.
- Otherwise → use **every discrete finding from the most recent substantive response** (blocking issues, suggestions, questions, recommended fixes, audit items, plan items).

For each finding, extract:
- Its current label / severity (e.g. blocking, non-blocking, nit, suggestion)
- The specific concern — what is being claimed as wrong, missing, or worth changing
- The proposed action — what would be done to address it
- The evidence cited — file:line, doc reference, command output, or "(none)" if absent

If a finding has no evidence cited, mark it for skeptical treatment — speculative findings rarely clear the bar.
