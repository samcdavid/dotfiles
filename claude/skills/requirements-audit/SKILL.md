---
name: requirements-audit
description: Deep requirements audit of a PR or feature against its spec. Traces every acceptance criterion to code, verifies user-facing behavior matches intent, identifies gaps and scope creep, and checks edge cases the spec implies but doesn't enumerate. Goes deeper than PM persona in a code review.
disable-model-invocation: true
---

# Requirements Audit

Perform a dedicated requirements traceability and completeness audit. This goes deeper than the PM persona in a code review — it's a focused pass verifying that what was built matches what was specified, catching gaps, edge cases, and unintended behavior changes.

## Getting Started

Determine scope:
- If `$ARGUMENTS` contains a PR number or URL → audit that PR
- If `$ARGUMENTS` contains a Linear ticket ID or URL → audit changes for that ticket
- If empty → ask the user what to audit

A requirements audit requires a spec to audit against. If neither a PR description nor a Linear ticket provides acceptance criteria, ask the user for the source of truth.

## Step 1 — Gather the Spec

### From Linear (primary source)
Fetch the linked ticket using Linear MCP tools:
- Title, description, acceptance criteria
- Sub-issues and their acceptance criteria
- Parent issue/project for broader context
- Comments — especially from PM, design, or stakeholders that clarify intent

### From PR Description
- PR description and any linked documents
- Commit messages for intent signals
- Linked Notion docs, Figma files, or external specs referenced in the PR

### From Notion (supplementary)
Search Notion for related design docs, RFCs, or specs:
- Pages that reference the Linear ticket ID
- Recent pages with matching feature/project names
- Meeting notes where requirements were discussed or refined

### Build the Requirements Map

Produce a structured requirements list:

```markdown
| # | Requirement | Source | Priority | Implicit Edge Cases |
|---|------------|--------|----------|-------------------|
| R1 | [Acceptance criterion verbatim] | [Linear/Notion/PR] | [Must/Should/Nice] | [Edge cases implied but not stated] |
```

**Implicit edge cases** — for every requirement, identify the unstated scenarios:
- What happens when the input is empty, nil, or malformed?
- What happens for the first/last item? For zero items? For one item?
- What happens when the user doesn't have permission?
- What happens when an external dependency is unavailable?
- What happens when the operation is retried or performed concurrently?

Present the requirements map to the user:
> "Here are the requirements I've extracted and the edge cases I'm inferring — is this complete and accurate?"

Do NOT proceed until confirmed.

## Step 2 — Trace Requirements to Code

For each requirement in the map:

### Code Mapping
Spawn parallel agents:
- **codebase-analyzer**: Read every changed file fully. For each requirement, identify the specific file(s), function(s), and line(s) that implement it.
- **codebase-pattern-finder**: Check how similar requirements were implemented elsewhere — is this implementation consistent with precedent?

Build a traceability matrix:

```markdown
| Requirement | Status | Implementing Code | Test Coverage | Notes |
|------------|--------|------------------|--------------|-------|
| R1 | Covered / Partial / Missing / Excess | `file:line` — [function] | `test_file:line` | [gaps or concerns] |
```

Statuses:
- **Covered** — requirement is fully implemented and tested
- **Partial** — some aspects implemented, others missing
- **Missing** — no corresponding code change found
- **Excess** — code exists that doesn't trace to any requirement (potential scope creep)

### Behavior Verification
For each "Covered" requirement, verify the implementation actually produces the specified behavior:
- Read the code path end-to-end — from user action to system response
- Check that the happy path matches the spec exactly (not approximately)
- Check that error/edge case paths produce reasonable behavior (even if not specified)
- Verify that the user-facing output (UI text, API response shape, email content) matches any design specs

### Edge Case Verification
For each implicit edge case identified in Step 1:
- Is it handled in the code?
- If handled, is the behavior reasonable?
- If not handled, could it cause a failure, data corruption, or confusing UX?

## Step 3 — Scope Analysis

### Scope Creep Detection
For every code change that doesn't trace to a requirement:
- Is it a necessary supporting change? (refactoring for the feature, test infrastructure, config)
- Is it a tangential improvement bundled into the PR?
- Is it an unrelated change that should be a separate PR?

### Requirement Drift
Compare the implementation against the original spec:
- Does the implementation interpret any requirement differently than intended?
- Are there implicit assumptions in the code that aren't in the spec?
- Has the scope expanded beyond what was specified? (more fields, more endpoints, more behavior)
- Has the scope contracted? (fewer fields, simplified behavior, deferred functionality)

### User-Facing Behavior Changes
Identify every change visible to end users:
- New UI elements, modified copy, changed layouts
- New or modified API responses
- Changed email/notification content
- Modified permissions or access levels
- Changed default values or behavior

For each, verify it was intentional (traces to a requirement) and not a side effect.

## Step 4 — Gap Analysis

### Missing Requirements
For each "Missing" or "Partial" requirement:
- Is it intentionally deferred? (check PR description, commit messages, comments)
- Is it blocked by something? (dependency, design decision, technical constraint)
- Is it simply overlooked?

### Missing Tests
For each requirement:
- Is there a test that specifically validates this requirement?
- Does the test check the right thing? (not vacuously passing)
- Are edge cases from Step 1 tested?
- Is the test at the right level? (unit for logic, integration for wiring)

### Missing Documentation
- Are user-facing changes reflected in documentation?
- Are API changes reflected in API docs or schemas?
- Are configuration changes documented?

## Step 5 — Adversarial Challenge

Before presenting, spawn the **adversarial-debate** agent to challenge your audit findings. A requirements audit that raises false gaps wastes PM and engineering time — precision matters.

Format all findings (missing requirements, scope creep, edge case gaps, behavior drift) as structured claims and pass them to the agent along with:
- The requirements map from Step 1
- The traceability matrix from Step 2
- The PR diff and full file contents for referenced code
- The Linear ticket and any Notion docs

The agent will:
- Verify that "Missing" requirements aren't actually covered by code you didn't trace — re-read the diff and grep for related identifiers
- Challenge "Excess" code claims — is it truly unrelated, or is it a reasonable supporting change?
- Steel-man scope creep — "you flagged this as unrelated, but the ticket description says 'clean up the surrounding code while you're in there'"
- Verify edge case claims — "you say nil isn't handled, but trace the callers — can this value actually be nil at this point?"
- Check that behavior verification reflects actual user experience, not just code reading — "you say the API response matches the spec, but did you check the serializer?"
- Calibrate severity — distinguish "requirement not implemented" from "requirement implemented slightly differently than one reading of the spec"

Apply the agent's verdicts:
- **KEEP**: gap is real and correctly classified
- **DOWNGRADE**: reclassify (e.g. "Missing" → "Partial" or "Covered with caveat")
- **REVISE**: narrow the claim based on evidence
- **DROP**: remove false gaps — note in "Considered and Dismissed" section

After applying verdicts, confirm:
- [ ] Every "Missing" finding was verified against the full diff (not just file names)
- [ ] "Excess" code claims account for reasonable supporting changes
- [ ] Edge case gaps reflect actual reachable code paths, not theoretical inputs

## Step 6 — Report

```markdown
## Requirements Audit: [Feature/Ticket]
Date: [ISO timestamp]
Spec sources: [Linear ticket, Notion doc, PR description]

### Summary
[2-3 sentences: overall coverage assessment — is the feature complete, partial, or significantly gapped?]

### Traceability Matrix
| # | Requirement | Status | Code | Tests | Notes |
|---|------------|--------|------|-------|-------|
| R1 | [Criterion] | Covered | `file:line` | `test:line` | |
| R2 | [Criterion] | Partial | `file:line` | — | [what's missing] |
| R3 | [Criterion] | Missing | — | — | [intentional or overlooked?] |

### Coverage: [N/M requirements covered] ([percentage]%)

### Missing or Incomplete Requirements
#### 1. [Requirement text]
**Status:** Missing / Partial
**Impact:** [What the user won't be able to do, or what will behave unexpectedly]
**Recommendation:** [Implement before merge / Defer with ticket / Acceptable as-is with documentation]

### Edge Case Gaps
#### 1. [Scenario]
**Requirement:** R[N]
**What happens:** [Current behavior when this edge case occurs]
**What should happen:** [Expected behavior based on spec or reasonable inference]
**Risk:** [Data loss / Bad UX / Error / Silent failure]

### Scope Analysis
#### Scope Creep (code not traced to requirements)
- `file:line` — [what it does, whether it should be separate]

#### Scope Contraction (requirements not fully addressed)
- R[N] — [what was deferred or simplified]

### User-Facing Behavior Changes
| Change | Intentional | Requirement | Notes |
|--------|------------|-------------|-------|
| [Description] | Yes/No/Unclear | R[N] or — | |

### Positive Findings
- [Requirements well-covered, good test strategy, clean scope]

### Considered and Dismissed
- [Findings that failed adversarial review]

### Recommendations
1. [Prioritized actions — what must happen before merge vs. what can follow up]
```

## Guidelines

- The spec is the source of truth — not your opinion of what the feature should do
- Missing requirements are higher priority than scope creep — shipping incomplete is worse than shipping extra
- Edge cases should be realistic, not exhaustive — focus on scenarios that users or systems will actually hit
- Be precise about "Missing" vs. "Partial" vs. "Implemented differently" — these have very different implications
- Scope creep is not inherently bad — flag it for awareness, don't treat it as a defect
- When the spec is ambiguous, say so — don't fill in gaps with your own interpretation
- Acknowledge what's done WELL — complete requirement coverage and clean scope deserve recognition
