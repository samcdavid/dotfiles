# Protocol — skill-my-pair-plan

This runner replaces `my-workflow`'s former serial research/spec/clarify/
architecture/test/plan/observe/eval/analyze artifact pipeline with one
resumable pair-planning conversation and one living issue ledger. Standalone
versions of those skills remain available.

## Invariants

- The issue corpus explains **what is needed**. Read it fully, but store only
  load-bearing needs, constraints, decisions, and source references.
- The workflow ledger explains **how the need will be met**. It is the only
  canonical pre-implementation document.
- Research factual questions before spending user attention. Ask one genuine,
  load-bearing decision at a time, with a recommended answer and consequences.
- Update the ledger immediately after every substantive user decision or
  verified deep dive. Show only a compact delta during the conversation.
- Compact means concise, not cryptic. Lead with the actual requirement,
  decision, test outcome, or plan change; include a ledger ID only afterward for
  traceability. Never ask the user to decode a key.
- Every decision, question, or active design discussion includes code context.
  Quote the smallest exact current excerpt that exposes the choice, with its
  file and starting line. If no implementation exists, show a clearly labeled
  proposed interface or pseudocode block. Never fabricate proposed code as if it
  came from the repository.
- A synchronized ledger is planning approval, not implementation authority.
- Missing or stale evidence fails closed to a focused deep dive or another
  conversation turn.

## Step 1 — Resolve or create the ledger

Detect the current branch first. Reuse a workflow ledger whose `branch` matches;
on the default branch fall back to Linear ID, slug, then topic. Never create a
second ledger for a branch unless the user explicitly replaces the prior
workflow.

For a new workflow, create
`~/.claude/thoughts/shared/workflows/<issue-or-topic-slug>.md` from the retained
template at `~/.claude/skills/my-pair-plan/references/ledger-template.md` (or the
equivalent `~/.agents` path). Record `planning_status: context`,
`implementation_authorized: false`, current branch/base, and `plan_version: 1`.

Treat frontmatter as the canonical workflow state. Whenever planning changes
increment `plan_version` and clear `planning_synced_at`,
`pre_implementation_check`, `checked_plan_version`,
`pre_implementation_checked_at`, `implementation_authorized`,
`authorized_plan_version`, and `implementation_authorized_at`. Reset the two
booleans/statuses to `false` and `not_run`; reset the remaining fields to null.

On every resume, read the ledger first. Apply `user_response` to the pending
decision or sync proposal before doing more work. Preserve rejected alternatives
and their rationale; do not silently rewrite history.

## Step 2 — Read the complete issue scope

When the task is a Linear issue, read the current issue's title, description,
and all comments. Build the sibling set deterministically and read each sibling's
title, description, and all comments:

1. Include every explicitly linked/related issue.
2. If the current issue has a milestone, include every issue in that milestone.
3. Otherwise, if it has a project, include every issue in that project.
4. Otherwise, stop at the explicitly linked/related issues.

Include every status and deduplicate issues reached through multiple routes.
Follow pagination until the full issue/comment set is read. The same issue must
appear once in the context index.

Do not copy this corpus into the ledger. Synthesize only the problem, desired
outcomes, constraints, acceptance criteria, prior decisions, dependencies,
conflicts, and facts that change the plan. Record issue IDs/URLs, retrieval
timestamp, and which source supports each load-bearing need. Mark ambiguous or
contradictory product intent as a pending decision rather than choosing silently.
Record the current issue, project, milestone, resolved sibling-scope rule, and
deduplicated sibling IDs in the corresponding frontmatter fields.

For a non-Linear task, apply the same boundary to the supplied file, URL, or
conversation and record the source index.

## Step 3 — Perform brief code orientation

Run `codebase-locator` and `codebase-analyzer` in parallel with the synthesized
need—not the raw issue corpus. Their bounded task is to identify the current
entry points, data flow, likely modules, existing tests, and obvious constraints.
Do not commission a comprehensive pattern survey or architecture plan yet.

Write a compact `Current-System Orientation` section with cited paths and the
known/unknown boundary. Set `planning_status: pairing`, increment
`plan_version`, and present:

- three to five facts that appear settled;
- a working hypothesis for what should change;
- confidence and the largest remaining uncertainty; and
- one load-bearing decision with a recommended answer and its code context.

## Step 4 — Pair through the plan

Treat subsequent turns as a working session, not an interview checklist. Cover
requirements, scope, implementation approach, architecture, testing,
observability, evaluation, migration/rollout, and operational readiness only to
the depth the change warrants.

For each candidate question:

1. Re-read the issue context, ledger, and earlier decisions.
2. Resolve knowable facts from code or sources.
3. If uncertainty is material, run the smallest focused deep dive from Step 5.
4. If a user-owned choice remains, state the current hypothesis and confidence,
   ask one question, give the recommended answer and evidence, and explain what
   changes if the recommendation is wrong.

Before returning that question, re-read the relevant source so the excerpt is
current. Select the smallest complete block that lets the user understand the
choice—usually the function/interface plus the relevant branch or call site.
Give its clickable path and starting line, use the correct fenced-code language,
and state in one sentence what to notice. Use additional excerpts only when the
decision genuinely spans boundaries and one block would mislead.

When there is no existing implementation surface, set `kind: proposed` and show
the smallest proposed signature, data shape, or pseudocode needed to make the
choice concrete. Say explicitly that it is a sketch, not repository code. A
product-only question must still show the proposed behavior at the nearest code
boundary rather than asking in the abstract.

After every answer, update the affected ledger sections and append a decision
row with status `confirmed`, `revised`, or `rejected`. Increment `plan_version`,
set `updated`, and return a compact delta before the next question. Do not wait
until final sync to persist conversation state.

## Step 5 — Route focused deep dives

Use existing agents as specialists, not as a serial artifact pipeline:

- Code behavior or convention: `codebase-analyzer` or
  `codebase-pattern-finder`, scoped to the exact uncertainty.
- External library/framework behavior: `docs-researcher`.
- Shipped-feature impact: `requirements-tracer` only when regression or blast
  radius is genuinely in question.
- Architecture: `skill-my-architecture-plan` with `mode: focused_advisory`.
- Test design: `skill-my-test-strategy` with `mode: focused_advisory`.
- Observability: `skill-my-observe` with `mode: focused_advisory` only for
  runtime behavior that needs instrumentation or rollout monitoring.
- AI/LLM evaluation: `skill-my-eval-plan` with `mode: focused_advisory` only for
  model-produced behavior.

Pass the ledger path, exact question, relevant requirements/decisions with both
their IDs and full descriptions, and only the cited code/source sections needed.
Advisory agents return evidence and
a proposed ledger-section patch; they do not create companion artifacts, ask
the user, or update the ledger. Apply a patch only after checking it against the
current conversation and sources. Record the agent and evidence under `Deep
Dives`.

Use `adversarial-debate` for a consequential disputed choice or when the final
plan has low-confidence architecture/test claims. Do not run it mechanically on
every section.

## Step 6 — Build implementation-ready sections

Continuously converge the ledger on:

- numbered requirements and explicit non-goals;
- confirmed decisions and rejected alternatives;
- architecture boundaries, interfaces, dependencies, and migration path;
- outcome-only test contracts with stable `TS-*` IDs, one smallest proving test
  per desired outcome, deterministic setup, and prohibited mechanism assertions;
- observability/evaluation applicability and design;
- migration and operational-readiness requirements;
- ordered implementation phases with `Tests First (RED)`, `Changes Required
  (GREEN)`, allowed paths, architectural constraints, and mechanical success
  criteria.

Trace every desired-outcome requirement `R-*` to one smallest `TS-*` contract
and implementation phase. Trace architecture, observability, performance, and
implementation constraints to a mechanical check without creating a test. Every
phase must be small enough for one delegated implementation task. Preserve the
existing RED → GREEN → VALIDATE contract.

## Step 7 — Propose synchronization

When no load-bearing question remains, set `planning_status: sync_pending` and
present the complete planning surface for review: need summary, scope,
requirements, decisions, architecture, test strategy, observability/evaluation,
migration/operations, phases, traceability gaps, and assumptions. Ask what is
wrong or missing and recommend either synchronization or a focused correction.

Only an explicit confirmation marks:

- `planning_status: synchronized`;
- `planning_synced_at: <timestamp>`;
- the current `plan_version` as the synchronized version; and
- every planning section complete or explicitly `not_applicable`.

A correction updates the ledger, increments `plan_version`, invalidates the old
sync, and returns to pairing or another sync proposal. Never set
`implementation_authorized: true`; `my-workflow` owns that later boundary.

## Output envelope

```markdown
status: needs_input | complete | blocked
ledger: { path: <path>, plan_version: <N>, planning_status: <state> }
delta: <sections and decisions updated this turn>
confidence: <0-100 plus largest uncertainty>
deep_dives: [<agent + exact question + evidence refs>]
next_decision: null | { question, recommendation, evidence, consequence }
code_context: null | {
  kind: current | proposed,
  path: <repository path or proposed target>,
  start_line: <line or null>,
  language: <fence language>,
  excerpt: <exact current code or clearly labeled proposal>,
  relevance: <what the user should notice>
}
sync_proposal: null | { summary, gaps, recommendation }
assumptions: [<verified factual assumption>]
external_action_requested: null | { actions, targets, rationale }
```

Every keyed item in this envelope must include its plain-language meaning. For
example, return “Use a five-minute cache TTL (`decision A-003`)”, never
“confirmed A-003”; return the full decision question and recommendation rather
than `next_decision: A-003`.

`code_context` is mandatory whenever `next_decision` is non-null or the turn
asks the user to discuss/choose an approach. A synchronization proposal includes
the smallest representative code context for any point it asks the user to
reconsider; it does not dump every touched file.

Return `complete` only after explicit synchronization. An unresolved decision,
stale issue context, malformed plan phase, uncovered requirement, or missing
migration safety work returns `needs_input` or `blocked`, never a false-ready
plan.
