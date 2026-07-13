## Session Mode — Validate Current Context

Use this mode to verify claims, findings, research, or code changes made during the current conversation.

### Step 1 — Inventory Claims

Review the conversation so far. Extract every verifiable claim:
- File paths mentioned (do they exist?)
- Code behavior described (does the code actually do that?)
- Architectural statements (is the dependency direction correct?)
- Changes made (did they produce the intended result?)
- Research findings (are they still accurate against current code?)

### Step 2 — Systematic Cross-Reference

For each claim, verify it against the actual codebase:

1. **File/path claims**: Glob to confirm existence
2. **Code behavior claims**: Read the code and trace the logic — does it match what was stated?
3. **Architectural claims**: Verify with actual imports, dependencies, call chains
4. **Change outcomes**: Run relevant tests or checks to confirm the change works
5. **Research accuracy**: Re-read referenced code to confirm findings are current

For each claim, record: VERIFIED, STALE, INCORRECT, or UNVERIFIABLE (and why).

### Step 3 — Self-Repair

For anything INCORRECT or STALE:
1. **Diagnose**: What's actually true vs. what was claimed?
2. **Correct**: Update the finding, fix the code, or flag the discrepancy
3. **Re-verify**: Confirm the correction is accurate

If a correction can't be made confidently, escalate to the user.

### Step 4 — Report

Present a concise validation summary:

```markdown
