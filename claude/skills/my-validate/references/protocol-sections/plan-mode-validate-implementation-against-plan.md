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
