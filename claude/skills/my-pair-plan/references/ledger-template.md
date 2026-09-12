---
task: <issue ID and title or topic>
branch: <current branch>
base_branch: <review base>
route: my-workflow
planning_status: context
plan_version: 1
planning_synced_at: null
pre_implementation_check: not_run
checked_plan_version: null
pre_implementation_checked_at: null
implementation_authorized: false
authorized_plan_version: null
implementation_authorized_at: null
linear_issue_id: null
linear_project_id: null
linear_project_name: null
linear_milestone_id: null
linear_milestone_name: null
sibling_scope: null
sibling_issues: []
issue_context_retrieved_at: <timestamp or null>
migration_safety: not_applicable
updated: <timestamp>
---

# Issue Delivery Ledger

## Need Summary

<!-- What the issue corpus requires; cite source issue IDs. -->

## Source Context Index

| Issue/source | Relationship | Retrieved | Load-bearing need |
| --- | --- | --- | --- |

## Current-System Orientation

<!-- Brief code context with file:line evidence and known/unknown boundary. -->

## Scope

### Included

### Excluded

## Requirements

<!-- IDs below are for cross-referencing this ledger only — never carry one into a file, module, class, function, method, variable, test, or attribute name. -->

| ID | Requirement | Type (`outcome` or `constraint`) | Source | Status |
| --- | --- | --- | --- | --- |

## Decisions

| ID | Question | Decision | Alternatives/rationale | Status |
| --- | --- | --- | --- | --- |

## Architecture

### Boundaries and Placement

### Interfaces and Dependencies

### Concurrency Model (PlusCal)

<!-- Required only when this change introduces or modifies a GenServer, OTP
process, actor, or other primitive whose correctness depends on interleaving
or shared state across concurrent execution. See
skill-my-architecture-plan/references/protocol.md Step 2b. Include the
PlusCal source, its safety/liveness invariant, the TLC result (or an explicit
note that it is unchecked), and a plain-language paragraph of what it proves.
Otherwise: not_applicable. -->

### Architectural Constraints

## Test Strategy

<!-- `TS-N` ids are for traceability only — never carry one into an actual test name, file name, or any other code identifier. -->

| ID | Desired outcome | Level | Setup/control | Outcome assertion | Do not assert |
| --- | --- | --- | --- | --- | --- |

## Observability

<!-- Design or explicit not_applicable rationale. -->

## Evaluation

<!-- AI/LLM evaluation design or explicit not_applicable rationale. -->

## Migration and Operational Readiness

<!-- Migration design; test-suite command and expected evidence; staging
validation checklist/status; rollout needs; env vars; flags; or not_applicable. -->

## Implementation Plan

### Phase 1 — <small behavior>

#### Allowed Paths

- `<path>`

#### Tests First (RED)

- [ ] `<TS-ID>` — <test and expected failure> (id is for traceability only — never carry it into the test's actual name)

#### Changes Required (GREEN)

- [ ] `<path>` — <change>

#### Architectural Constraints

- <constraint>

#### Success Criteria

- [ ] <mechanical command/assertion>

## Traceability

| Requirement | Test/mechanical check | Phase |
| --- | --- | --- |

## Deep Dives

| Date | Agent | Question | Evidence incorporated |
| --- | --- | --- | --- |

## Pre-Implementation Check

<!-- Evidence summary only. Canonical gate and authorization state is in frontmatter. -->

## Execution Log

<!-- Existing my-implement, whole-plan my-validate, and implement-review outcomes append here. -->

## Finding Register

| Key | Status | Finding | Evidence and disposition | Commit or follow-up | Recorded |
| --- | --- | --- | --- | --- | --- |
