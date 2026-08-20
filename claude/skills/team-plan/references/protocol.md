# Protocol — team-plan

`SKILL.md` is the entrypoint. This protocol turns a proposal or an existing Linear project into a researched, reviewable delivery draft, and only creates Linear records after explicit approval.

## Outcome and boundaries

Act as the project-discovery and delivery-planning lead. Produce these connected artifacts:

1. A requirements brief that distinguishes verified facts, assumptions, decisions, non-goals, and the new functionality.
2. Codebase research and a requirement-to-gap map showing what exists, what is missing, and the evidence for each claim.
3. Job stories that describe the user or operator outcome the project must deliver.
4. PR-backed issue drafts, migration sequencing when applicable, milestones, dependencies, surfaces, conflicts, and parallel waves.
5. An exact Linear creation/update manifest that remains a draft until the user approves it.

Do not change application code, create PRs, run test suites, or write to Linear during discovery and planning. Read-only Linear, repository, docs, and operational investigation is in scope. Save durable artifacts under `~/.claude/thoughts/shared/` (or the equivalent shared artifact root in the active runtime). Existing Done work is context, never something to reopen or rewrite.

## Delegation and model routing

Keep this coordinator, artifact assembly, and all Linear reads/writes on the caller's model. Use the named runners below for the high-judgment work; their generated agent configuration deliberately supplies the model and reasoning tier. Do not substitute a generic agent or in-context summary for a required runner.

| Work | Required delegate | When / handoff |
|---|---|---|
| Product requirements and acceptance criteria | `skill-my-spec` (Terra/high) | Always for a new project proposal or materially incomplete existing scope. Give it the product context and `authority: local_only`; consume its spec artifact and provisional decisions. |
| Codebase and delivery-context gap research | `skill-my-research` (Sol/xhigh) | Always when a repository or existing system is in scope. Give it the accepted/current spec artifact, relevant Linear/doc context, and the question "what exists, what gaps remain, and what constrains delivery?" Its own protocol fans out locator, analyzer, and pattern discovery and adversarially verifies findings. |
| Structural design | `skill-my-architecture-plan` (Sol/high) | Required when the project crosses module boundaries, introduces or changes a public contract, or changes persisted data. Pass the spec and research artifacts; turn its falsifiable constraints into issue boundaries and conflict rules. Skip only when research demonstrates a contained, single-module change. |
| Final plan challenge | `adversarial-debate` (Sol/xhigh) | Always. Give it the requirements/spec, verified gaps, architecture constraints where present, job stories, issue/milestone drafts, dependencies, and conflict matrix. Apply supported corrections before presentation. |

Use targeted `codebase-locator`, `codebase-analyzer`, and `codebase-pattern-finder` calls only as scoped follow-ups to the research or architecture runner, or when they need one bounded missing fact. Their Terra routing makes them suitable for parallel evidence gathering; they do not replace Sol's research synthesis. If the research, specification, and architecture outputs conflict, return the conflicting evidence to `skill-my-research` for Sol-led resolution before defining issues.

## Inputs and defaults

Accept a product brief, a Linear project/milestone/issue URL, a project name, or a combination. Search Linear before assuming the project does not exist. Read linked issues, comments, projects, milestones, product documents, and prior completed work that could establish behavior or constraints.

Use the team size from the request or known assignees. If it is absent, use a planning capacity of eight. Aim for six to eight independently mergeable, PR-sized issues in a normal feature wave when the team has that capacity. A migration-readiness wave, a genuine dependency chain, or a small project may safely contain fewer; state why. Never manufacture tickets, abstractions, or split a coherent PR merely to reach a concurrency count.

Ask only for a consequential product decision that cannot be resolved from the available evidence. Treat factual gaps as research work, record their evidence and result, and continue. If a decision must remain unresolved, preserve options, recommendation, and impact in the draft rather than hiding it.

## Hard constraints

- Every implementation issue represents one coherent, independently reviewable PR. Include its planned PR boundary in the issue draft; do not create a PR while planning.
- Do not create standalone issues for enabling, disabling, or flipping feature toggles. Put that work in the functional issue whose behavior it controls, with its rollback/rollout acceptance criteria.
- Generated files alone do not count as a conflict. Shared handwritten source, contracts, migrations, schemas, configuration, or ownership boundaries do.
- Two issues with a HIGH conflict cannot be concurrent unless an explicit, minimal coordination interface makes independent PRs possible. Prefer resequencing to creating a coordination interface.
- A database migration must never share an issue or PR with the functional behavior it enables. The migration-only issue is an explicit predecessor and must be deployed before dependent functional work ships. Read `migration-planning.md` whenever this applies.
- Every issue must trace to at least one job story and specific acceptance criteria. Remove or merge work that has no such trace.
- No Linear create, update, comment, relationship change, or status change occurs until the final approval step. Do not use an early "inventory confirmation" as permission to mutate Linear.

## Step 1 — Requirements discovery and specification

Collect the proposal and all available product context from the conversation, Linear, Notion/Drive, existing documentation, related projects, and completed work. Dispatch `skill-my-spec` with that bounded context and `authority: local_only`. It owns requirements discovery, research-before-questioning, and the product-spec artifact; do not reproduce that work in the coordinator.

Use its spec artifact to produce a requirements brief with:

| Area | Required content |
|---|---|
| Problem and audience | Who has the problem, why it matters, and the triggering situation |
| New functionality | Observable capabilities and changed behavior, not implementation guesses |
| Success and acceptance | User-visible outcomes, measurable success where available, failure/edge behavior |
| Scope boundaries | Explicit non-goals, compatibility needs, rollout constraints, and dependencies |
| Evidence and certainty | Source for each fact; clearly mark assumptions and unresolved decisions |

If an existing milestone or issues were supplied, inventory them as proposed work, not as authoritative requirements. Identify stale, duplicate, or missing scope before designing the project around them. If the spec runner returns a load-bearing `needs_input` result, obtain that decision before research. Otherwise carry its provisional decisions forward as visible planning risks. Save the brief as `plans/NNN_requirements_<project-slug>.md`, linked to the spec artifact.

## Step 2 — Codebase and delivery-context research

Research before breaking the work into issues. Dispatch `skill-my-research` with the requirements/spec artifact, project context, and a bounded gap question. It owns verified discovery and its mandatory Sol/xhigh adversarial challenge. Do not replace its verified findings with a coordinator-only summary.

Use its artifact to establish:

- Relevant entry points, modules, data models, APIs, UI or job flows, test coverage, configuration, and generated-code boundaries.
- What currently happens for each requirement, with file/function/schema evidence.
- Existing patterns that should be reused and prior work that already satisfies part of the request.
- In-progress sibling work in Linear and completed work that constrains compatibility or ownership.
- Whether persisted data/schema changes are needed, and any Ecto migration history or deployment constraints.

Do not stop at file discovery. Trace the behavior sufficiently to say whether the requirement is already satisfied, partially satisfied, absent, or contradicted by existing behavior. Record a gap map:

| Requirement / new functionality | Current evidence | Gap | Candidate delivery boundary | Confidence / unknown |
|---|---|---|---|---|

Save the evidence and gap map as `research/NNN_project_gap_<project-slug>.md`, linked to the runner artifact. If the runner identifies conflicting evidence or scope that invalidates the spec, route that evidence back to `skill-my-spec` once for a revised spec before continuing.

## Step 3 — Job stories and delivery units

Before defining delivery units, dispatch `skill-my-architecture-plan` with the spec and research artifacts when the routing table requires it. Treat its constraints, dependency directions, and contract decisions as binding issue-boundary inputs. If it is skipped, record the research evidence that the project is contained and why structural design is unnecessary.

Turn each validated gap into job stories. Use outcome language:

> When [situation], I want to [motivation], so I can [expected outcome].

For every job story record the linked requirement(s), current gap, acceptance outcomes, non-goals, dependencies, and any risk to existing users/operators. Split a story only when its delivery can be independently reviewed and merged. Combine implementation details that only make sense together in one PR.

Then draft issues. Each issue must include:

- Clear title, linked job story IDs, user/value statement, and why it is needed now.
- In-scope and out-of-scope behavior; acceptance criteria that make the PR reviewable.
- Current-state evidence, affected handwritten code/data surfaces, expected tests, and relevant local patterns.
- Planned PR boundary: exactly one implementation PR, with generated files called out separately from handwritten overlap.
- Dependencies, milestone, target wave/slot, and conflict/coordination notes.
- Rollout, observability, compatibility, and toggle details only when they are needed to deliver that issue's behavior.

Do not create tickets for task administration, toggles, broad research, vague layers, or speculative cleanup. Put genuinely prerequisite research into the affected issue's definition unless it warrants a distinct, independently mergeable PR with a job-story outcome.

## Step 4 — Migration-only planning

When Step 2 finds Ecto schema/data work, load `migration-planning.md`. Create one or more migration-only issues before their dependent functional issues. Their acceptance criteria must name the safe operation recipe, deployment/compatibility prerequisite, validation evidence, and the exact functional issue(s) they unblock.

The initial migration milestone/wave contains only forward-compatible schema preparation, indexes, constraints, data preparation, or backfill machinery; it deliberately ships no feature behavior. Mark dependent functional issues blocked until that migration is deployed and verified. For an expand/migrate/contract change, deferred cleanup or destructive contract work remains a separate, later migration-only issue after the compatibility interval. This is a required safety exception to "beginning of project," not permission to combine it with functional work.

## Step 5 — Surface, dependency, and conflict analysis

For each proposed issue, determine the likely handwritten files/modules, functions, schemas, contracts, configuration, and migration objects it will write. Use the broad research to avoid guesses. If the surface remains unclear, refine the issue before scheduling it; do not hide uncertainty in a wave assignment.

Build both a dependency graph and conflict matrix:

- **HIGH:** same handwritten function, schema/migration object, contract, or ownership boundary would be edited incompatibly.
- **MED:** same handwritten file/area with additive but merge-sensitive work.
- **LOW:** shared read-only type or interface; no planned write overlap.
- **NONE:** no meaningful handwritten overlap. Generated output by itself is `NONE`.

For HIGH/MED pairs, include the merge order, most likely regression tests, and the smallest coordination interface only if resequencing cannot remove the conflict. Save the analysis as `plans/NNN_surface_conflicts_<project-slug>.md`.

## Step 6 — Milestones and parallel waves

Organize issues by independently shippable user value and dependencies, not by arbitrary technical layers. A project may have:

1. A migration-readiness milestone/wave, when required, before functional delivery.
2. Feature milestones containing six to eight independent PR-backed issues per wave when feasible.
3. Explicit later compatibility-cleanup migration milestones only when safe Ecto sequencing requires them.

Within a wave, assign each issue to one developer/agent slot. Every PR must be mergeable independently; a wave may start only after its declared prerequisites are deployed or merged. Favor the fewest waves and coordination interfaces that satisfy real dependencies and HIGH conflicts. For a single developer, emit a critical-path order rather than pretending parallelism exists.

For every milestone and wave, state its goal, included issues, prerequisites, intended parallelism, critical path, dependency links, and why any capacity is below the six-to-eight target. Save the draft as `plans/NNN_team_plan_<project-slug>.md`.

## Step 7 — Reviewable planning package

Present a concise package containing:

- Requirements brief and unresolved decisions.
- Requirement-to-gap map with evidence.
- Job stories and traceability to issue drafts.
- Proposed milestones, wave plan, PR ownership boundaries, dependency graph, conflict matrix, and critical path.
- Migration-only sequencing and safety checks, or an explicit finding that no Ecto migration is required.
- Existing Linear project/milestone/issue records that will be reused, and duplicates or stale draft records that will not be changed without direction.

Also prepare an exact Linear manifest: project create-or-reuse decision, project description, milestones to create, issue titles/descriptions, membership, dependencies, and any planned comments. Before presenting it, dispatch `adversarial-debate` with the complete evidence bundle described in the routing table. Apply its KEEP/REVISE/DROP/PROMOTE verdicts; do not present contradicted requirements, unverified gaps, or an issue that lacks traceability. This is the sole approval boundary. Ask for explicit approval to apply that manifest; a general request to plan is not authorization.

## Step 8 — Create Linear records after approval

After the user explicitly approves the manifest:

1. Re-query Linear for the named project, milestones, and matching issues to avoid duplicates or changes since the draft.
2. Reuse the existing project if it is the intended one; otherwise create it with the approved description and link to the planning artifacts.
3. Create the approved milestones and PR-backed issues with their full descriptions, then set project/milestone membership and dependency relationships.
4. Verify every created record, capture IDs/URLs, and compare the result with the approved manifest.

If Linear rejects part of the manifest or current state makes it ambiguous, stop and report the exact completed records and remaining difference. Do not silently retry by creating duplicates or broaden the approved scope. Return the final URLs, created/reused status, and any follow-up that still needs explicit approval.

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting work.
