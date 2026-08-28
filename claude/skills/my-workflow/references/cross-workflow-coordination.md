# Issue Context and Cross-Workflow Coordination

Use for Linear issue intake, the pre-implementation refresh, and the final
post-review sibling-state check. Issue contents define what is needed; the
ledger defines how this workflow will meet it.

## Context scope

Read the current issue's title, description, and all comments. Build and fully
read the sibling set in this order:

1. Every explicitly linked/related issue.
2. If the current issue has a milestone, every issue in that milestone.
3. Otherwise, if it has a project, every issue in that project.
4. Otherwise, only explicitly linked/related issues.

Include every issue status, follow pagination, and deduplicate issues reached by
multiple routes. For each issue, read title, description, and all comments.

Store only a synthesized need/source index in the ledger: issue ID/URL,
relationship, retrieval timestamp, load-bearing requirements/constraints,
dependencies, decisions, and conflicts. Do not copy the full issue corpus.

## Initial planning use

`my-pair-plan` reads this full scope before code orientation. Sibling existence
is context, not automatically an overlap or blocker. Use the corpus to understand
the milestone/project intent and avoid planning duplicate or contradictory work.

## Pre-implementation refresh

After the ledger is synchronized, re-fetch the same exact scope rather than
reusing intake payloads. Compare it with the ledger's source index:

- New or changed load-bearing need invalidates synchronization and returns to
  pair planning.
- Status/comment changes without planning impact update the source index and do
  not invalidate the plan.

Then compare the current plan's exact files, modules, schemas, contracts, and
requirements with sibling ledgers, plans, diffs, and issue contents. Escalate
only a material file/module collision or duplicated/contradictory requirement.
Present one decision with options, recommendation, and evidence. A clear scan
records `passed` for the current plan version.

## Final refresh

After review reaches a terminal result, refresh sibling state once more because
implementation may have taken time. Report any new overlap; do not restart or
mutate completed work automatically.

## Ledger fields

```yaml
linear_issue_id: <id>
linear_project_id: <id or null>
linear_project_name: <name or null>
linear_milestone_id: <id or null>
linear_milestone_name: <name or null>
issue_context_retrieved_at: <timestamp>
sibling_scope: linked_plus_milestone | linked_plus_project | linked_only
sibling_issues: [<IDs>]
pre_implementation_check: not_run | passed | overlap_pending | invalidated
checked_plan_version: <version or null>
```

This is not `team-plan`: it understands related work for one issue and checks
collisions, but does not assign or sequence an entire milestone.
