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

| ID | Requirement | Source | Status |
| --- | --- | --- | --- |

## Decisions

| ID | Question | Decision | Alternatives/rationale | Status |
| --- | --- | --- | --- | --- |

## Architecture

### Boundaries and Placement

### Interfaces and Dependencies

### Architectural Constraints

## Test Strategy

| ID | Requirement/risk | Level | Setup/control | Observable assertion | Do not assert |
| --- | --- | --- | --- | --- | --- |

## Observability

<!-- Design or explicit not_applicable rationale. -->

## Evaluation

<!-- AI/LLM evaluation design or explicit not_applicable rationale. -->

## Migration and Operational Readiness

<!-- Compatibility matrix, rollout needs, env vars, flags, or not_applicable. -->

## Implementation Plan

### Phase 1 — <small behavior>

#### Allowed Paths

- `<path>`

#### Tests First (RED)

- [ ] `<TS-ID>` — <test and expected failure>

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

<!-- Existing my-implement and implement-review outcomes append here. -->

## Finding Register

| Key | Status | Finding | Evidence and disposition | Commit or follow-up | Recorded |
| --- | --- | --- | --- | --- | --- |
