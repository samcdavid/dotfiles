---
name: my-validate
description: Verify and validate work — either against a plan file or against the current session context. Runs mechanical checks, cross-references claims against code, and attempts self-repair before escalating failures.
disable-model-invocation: true
---

# Validate

Systematically verify work. This skill doesn't just REPORT failures — it attempts to CORRECT them (inform/verify/correct cycle).

Operates in one of two modes depending on context.

---

## Mode Selection

- If `$ARGUMENTS` contains a path to a plan file, use **Plan Mode**.
- If `$ARGUMENTS` is `session` or empty and there is no plan context, use **Session Mode**.
- If ambiguous, ask the user which mode they want.

Regardless of mode: after identifying the active plan (from `$ARGUMENTS` or session context), check for a companion observability plan. Look in `~/.claude/thoughts/shared/plans/` for a file matching `*a_*observability*` whose `parent_plan` frontmatter points to the active plan. If found, run **Observability Validation** as an additional phase appended to the normal validation report.

---

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
## Session Validation Report

### Verified
- [claim] — confirmed at `file:line`

### Corrected
- [original claim] → [actual finding] — [what was fixed]

### Needs Attention
- [claim] — [why it couldn't be verified or fixed]

### Recommendations
- [next steps if any]
```

---

## Plan Mode — Validate Implementation Against Plan

Use this mode to verify that an implementation correctly matches a plan.

### Step 1 — Context Discovery

1. Read the plan file (from `$ARGUMENTS` or list plans in `~/.claude/thoughts/shared/plans/` and ask)
2. Identify ALL files that should have changed
3. Collect ALL success criteria (mechanical checks)
4. Collect ALL architectural constraints
5. Spawn parallel agents to discover the current state:
   - **codebase-locator**: Find all files mentioned in the plan
   - **codebase-analyzer**: Analyze the implemented code

### Step 2 — Systematic Verification

For each phase in the plan:

#### 2a. Completion Check
- Verify each `[ ]` / `[x]` checkbox — does the code reflect it?
- Read every file listed in "Changes Required" — was the change actually made?

#### 2b. Mechanical Success Criteria
Run EVERY command listed in success criteria. For each:
- Record: PASS or FAIL
- If FAIL: capture the error output

#### 2c. Architectural Constraint Check
Verify no architectural constraints were violated:
- Dependency directions respected
- Module boundaries maintained
- Naming conventions followed
- No unintended side effects in files NOT listed in the plan

#### 2d. Entropy Detection
Check for unintended drift:
- Files modified that weren't in the plan — intentional or accidental?
- Dead code introduced (unused imports, unreachable branches)
- Inconsistencies between the change and surrounding code

### Step 3 — Self-Repair Loop

For each FAILURE from Step 2:

1. **Diagnose**: Identify the root cause (not just the symptom)
2. **Attempt fix**: Make the correction
3. **Re-verify**: Run the same check again
4. **Escalate if stuck**: If the same check fails after 2 repair attempts, STOP and present the problem to the user with:
   - What was expected
   - What actually happened
   - What you tried
   - Why you think it's failing

### Step 4 — Generate Validation Report

```markdown
## Validation Report: [Plan Name]
Date: [ISO timestamp]

### Overall Status: [PASS / PARTIAL / FAIL]

### Phase-by-Phase Results

#### Phase 1: [Name]
- Completion: [X/Y changes verified]
- Success Criteria: [X/Y passing]
  - `command` — PASS
  - `command` — FAIL (repaired) / FAIL (needs attention)
- Constraint Violations: [none / list]

#### Phase 2: [Name]
...

### Self-Repairs Made
- [What was wrong → what was fixed → verification result]

### Issues Requiring Attention
- [Issue, root cause analysis, recommended fix]

### Entropy Check
- Unplanned file changes: [list or "none"]
- Dead code detected: [list or "none"]

### Recommendations
- [Prioritized next steps]
```

Update the plan file's status to `validated` or `needs-attention`.

---

## Observability Validation (Auto-triggered when a companion plan exists)

When a companion observability plan is detected, validate that the instrumentation described in it was actually implemented.

### Step 1 — Parse the Observability Plan

Read the observability plan file. Extract:
- Every **metric** (name, type, source file/function)
- Every **span** (name, location)
- Every **log statement** (location, expected fields)

### Step 2 — Verify Implementation in Code

For each instrumentation point, read the source file(s) listed and verify:

1. **Metrics**: Is the counter/histogram/gauge emitted at the described location? Do the tag/label names match?
2. **Spans**: Is `tracer.trace(...)` (or equivalent) wrapping the described block? Are the specified attributes attached?
3. **Logs**: Is the log statement present with the expected fields/format?

Record each as: IMPLEMENTED, MISSING, or PARTIAL (present but deviates from plan).

### Step 3 — Self-Repair

For anything MISSING or PARTIAL:
1. Diagnose what's actually in the code vs. what the plan specifies
2. Implement the missing instrumentation or correct the deviation
3. Re-verify

If a fix can't be made confidently (e.g. platform-specific setup needed, unclear ownership), escalate to the user.

### Step 4 — Append to Validation Report

Add an **Observability** section to the validation report:

```markdown
### Observability Validation

#### Metrics
- `metric.name` — IMPLEMENTED at `file:line` / MISSING / PARTIAL (deviation)

#### Spans
- `span.name` — IMPLEMENTED at `file:line` / MISSING / PARTIAL

#### Logs
- `log_statement` at `file:line` — IMPLEMENTED / MISSING / PARTIAL

#### Self-Repairs Made
- [What was missing → what was added → verification result]

#### Issues Requiring Attention
- [Issue, reason it couldn't be auto-fixed]
```

Update the observability plan's `status` to `validated` or `needs-attention`.

---

## Guidelines (Both Modes)

- Run ALL checks — don't stop at the first failure
- Be thorough but practical — verify what matters, don't nitpick formatting
- Think critically about maintenance and long-term implications
- Distinguish between "broken" and "different from plan but acceptable"
- The goal is CORRECTNESS, not compliance for its own sake
- Every claim must be checked against ACTUAL CODE, not assumed from memory
