## Step 2 — Cursory Pass: Identify Review Lenses

Do a quick triage to pick which review **lenses** apply. Lenses drive which reviewer subagents you spawn in Step 3 and which deep-dive subsections appear in the final review.

### Inputs

- PR description, commit messages
- Linked Linear issue(s), referenced specs / RFCs / design docs (fetch them — don't infer)
- File-level scan of the diff: which areas changed? (backend / frontend / migrations / config / infra / tests / docs / dependency manifests)
- Existing reviewer assignments or labels on the PR

### Lens catalog

| Lens | Scrutinizes | Trigger signals |
|---|---|---|
| **Backend** | Data integrity, query performance, idempotency, error handling, transactions, race conditions, job safety | Server-side code, contexts, schemas, queries, jobs, workers |
| **Frontend** | Accessibility, responsive behavior, state management, render performance, UX consistency, design system adherence | UI components, hooks, stores, CSS, design tokens |
| **Full-stack** | Backend + Frontend with cross-layer wiring scrutiny | Both areas touched in one change |
| **Security** | Auth/authz, input validation, injection vectors, secrets, CORS/CSP, token handling | Auth code, input handlers, queries with user input, file upload, external API creds, security headers |
| **Architecture** | System boundaries, coupling, abstraction quality, scalability, contract design, migration paths | New modules/services, changes to module boundaries, new dependency directions, new infra patterns |
| **Ops** | Deployment safety, observability, failure modes, rollback paths, resource usage, configuration | Health checks, logging, feature flags, config files, deploy manifests, env vars, resource limits |
| **QA** | Test fidelity, coverage gaps, assertion quality, flakiness, test architecture | Test files added/modified, mocks/stubs, new modules without tests |
| **PM** | Requirements coverage, acceptance criteria traceability, scope creep, user-facing behavior | Linked ticket with detailed acceptance criteria, new user-facing behavior |
| **Performance** | Hot-path queries, N+1, caching, indexes, unbounded loops, large-table queries | Queries on large tables, hot endpoints, queue/concurrency changes, caching logic |
| **Migration safety** | Lock risk, down-migration safety, column types, advisory locks, backfillers | Migration files in the diff |
| **Dependency** | License, maintenance, attack surface of new packages | Lockfile changes, new dependency manifests |

If the change has no obvious lens fit, default to **Backend + Security + QA**.

### Requirements checklist (if a ticket is linked)

If the PR description links to a Linear ticket (e.g. `ENG-123`, `Fixes ENG-123`, Linear URL), fetch it via the Linear MCP and build a `requirements_checklist`: title, description, acceptance criteria, sub-issues. Pass this to the `requirements-reviewer` (and activate the PM lens).

If a caller supplies a **spec or requirements document** directly (e.g. `my-workflow` passes the stage-2 spec path, or `$ARGUMENTS` names a spec/PRD), read it and build the `requirements_checklist` from its acceptance criteria the same way — a spec is an equally valid requirements source, and takes precedence when both a spec and a ticket are present. Activate the PM lens whenever any requirements source exists.

### Tracer triggers

Set `tracer_triggers.neighbor_commits_heuristic = true` if any of the diff's changed files appear in commits whose messages reference a closed Linear issue from `git log --since=60.days --name-only --pretty=format:'%H %s'`. This is the only signal that needs main-context git access — the others (PM lens active, ticket linked, requirements-audit escalated) are already known from triage.

### Plan-file lookup

Check `~/.claude/thoughts/shared/plans/` for a plan file matching the linked Linear ticket (filename or `feature:` frontmatter). If found, read the plan's surfaces (Phase sections, "Changes Required" lists, "What We're NOT Doing") and hold them as `plan_surfaces` — you'll pass them to `requirements-tracer` if it runs in Step 3.

### Triage output

Produce a short triage block and show it to me before going deep:

```
### Review Triage
- **Intent:** <1–2 sentences in your words — what this change does and why>
- **Lenses identified:**
  - <Lens> — <one-line rationale grounded in the diff>
  - <Lens> — <one-line rationale grounded in the diff>
- **Requirements checklist:** built from <ticket ID> | none linked
- **Tracer triggers:** <list which fired, or "none">
- **Author calibration (PR Mode):** <Junior | Mid | Senior | Lead | Staff+> — see below
- **Auto-promoted since last review:** <count> · <target file(s) + Shape one-liner(s)> (or "none")
- **Pending learned misses:** <count> (run `/my-review promote` to triage early)
```

To populate the last two lines, scan `references/learned-misses.md`:
- Pending count = entries with `status: pending` or `status: ready` under `## Pending`.
- Auto-promoted-since-last-review = entries under `## Promoted` whose `status: promoted (<date>)` is newer than the last completed review. If you can't determine the prior review timestamp, list any promotion dated within the last 14 days.

If `status: ready` entries exist (auto-promote blocked on ambiguous target), call them out by name — these need your input.

Proceed automatically unless I override.

### Author Skill Level (PR Mode only)

Ask which skill level to calibrate against. Skip for Local Mode.

| Level | Calibration |
|---|---|
| **Junior** | Thorough and educational. Explain *why*. Encouraging on good work. |
| **Mid** | Standard. Explain non-obvious issues. Trust they can implement fixes given a clear problem description. |
| **Senior** | Concise and direct. Focus on subtle bugs and architecture. Skip explanations of well-known patterns. |
| **Lead** | Concise and strategic. Maintainability, team-wide impact, precedent. |
| **Staff+** | Peer review. Systemic impact, cross-team implications, design tradeoffs. Frame as discussion. |

Default: **Lead** if I skip.
