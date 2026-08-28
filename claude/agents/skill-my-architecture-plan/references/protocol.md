# Protocol — skill-my-architecture-plan

Full private procedure for the `skill-my-architecture-plan` runner. The `my-architecture-plan` wrapper normalizes request context, preserves the user-facing decision boundary, and presents the compact result. Retained standalone gotchas remain under the skill directory.

## Architecture Plan

Design the architectural shape of a change — module placement, coupling and cohesion, boundary and dependency design, and any deliberate deviation from convention — before `my-plan` writes implementation phases. This is `my-arch-review`'s judgment applied one step earlier: instead of grading a diff that already exists, decide the structure a not-yet-written change should take.

## Focused advisory mode

When `mode: focused_advisory`, answer only the supplied architectural question.
Read the living ledger and cited code/source sections, then apply the relevant
criteria below without launching the full three-agent discovery wave, asking the
user, or creating an artifact. Run additional discovery only for a fact the
bounded evidence cannot settle. Return cited evidence, alternatives and a
recommendation, confidence, affected requirements/decisions as ID plus full
description, and a proposed patch for the ledger's Architecture section. The pair-planning coordinator
decides whether to apply it. Return immediately; the remaining artifact workflow
applies only outside advisory mode.

## Workflow Ledger (read first)

This skill runs both standalone and as a stage inside `/my-workflow`, positioned after `my-clarify` and before `my-plan`. Before anything else, look for the task's workflow ledger:

- Search `~/.claude/thoughts/shared/workflows/` for a ledger matching this task (by current git branch first, then Linear ID, ticket slug, or topic — same detection order `my-workflow` itself uses).
- **If one exists, read it fully.** Consume the linked research doc and clarified spec by path rather than re-discovering them — the problem statement, acceptance criteria, and scope decisions are already settled there. This skill only adds the *structural* design layer on top.
- **When you finish, if a ledger exists, append this stage's outcome only in standalone mode**: the architecture-plan path and any assumptions/decisions recorded here. In embedded mode, return that data in the output envelope so `my-workflow` records it itself.
- If no ledger exists, proceed without one — do not create a workflow ledger yourself (that is `/my-workflow`'s job).

## Getting Started

Determine the task without a blank prompt:
- If the input `task` names a task, ticket, spec, or file paths → use it.
- If empty → read the conversation context, the workflow ledger, and any adjacent spec/research first, then open with a concrete proposal of what you're about to design.
- Only fall back to "Ready to plan the architecture. Describe the change, or point me at a spec/ticket." when there is genuinely nothing to go on.

## Step 1 — Learn the Existing Architecture

Before designing anything, understand the system as it exists today. Spawn parallel agents:

- **codebase-locator**: Map the top-level directory structure, module boundaries, and key entry points.
- **codebase-analyzer**: Trace dependency directions between major modules — what imports what, what calls what.
- **codebase-pattern-finder**: Identify established conventions — file organization, naming patterns, layering, how similar features were structured before.

Look for:
- Project CLAUDE.md, AGENTS.md, or architecture docs that define intended structure.
- Existing ADRs (Architecture Decision Records) in `docs/`, `adr/`, or similar.
- Dependency layering (e.g., Types → Config → Repo → Service → Runtime → UI).
- Module boundary patterns (how the codebase separates concerns today).

State your understanding of the architecture before proceeding:
> "Here's how I understand the current architecture and its conventions — is this accurate?"

## Step 2 — Design the Change's Structure

**Criteria source of truth:** `~/.claude/skills/my-arch-review/references/protocol.md`, Step 2. Read it — do not reinvent the checklist here. Apply its five categories (Structural Fit, Coupling Analysis, Cohesion Analysis, Boundary Integrity, Dependency Health) to the *planned* change, reframed as decisions to make rather than judgments on an existing diff:

- **Structural Fit** → *Decide* which existing module the change belongs in, or whether a new module is warranted — per the codebase's established boundaries and layering, not convenience. If introducing a new pattern, it must be better than the established one and worth the inconsistency; state why.
- **Coupling Analysis** → *Design* the new dependency edges before they exist, minimizing coupling between modules that should stay independent. Watch for hidden coupling you're about to introduce (shared mutable state, implicit contracts, temporal coupling) — not just direct imports.
- **Cohesion Analysis** → *Decide* how to group the new code so a future developer would find it where they'd expect, by what it does. Don't let one concern scatter across unrelated modules because that's where the individual pieces were easiest to add.
- **Boundary Integrity** → *Design* the public interface/contract this change introduces or touches before implementation — keep it minimal, avoid leaking implementation details across the boundary. If crossing a service boundary, make the contract explicit and versioned from the start.
- **Dependency Health** → *Decide* what depends on what. Prefer depending on abstractions over concretions. Place any new third-party dependency at the correct layer, not deep in domain logic. Keep dependency direction acyclic.

Since there is no diff to read yet, ground every decision in Step 1's actual findings (file:line evidence, real import graphs) — a plausible-sounding placement that contradicts the codebase's actual layering is worse than no plan at all.

## Step 2a — Interface & Contract Design

Applies whenever the planned change adds, extends, or crosses a public interface: an API endpoint, a cross-service contract, or a module's public function surface. Skip this step for a purely internal, single-module change with no external callers.

- **Contract first.** Design the shape — request/response types, function signature, event schema — before the implementation that fills it in. Write the shape into the plan's Interface & Contract Design section verbatim; `my-plan`/`my-implement` should not have to infer it from prose.
- **Hyrum's Law.** Once an interface has consumers, every observable behavior becomes a de facto dependency, not just the documented contract. Keep the surface minimal and intentional — don't expose incidental behavior (internal ordering, timing, error message text) that isn't meant to be relied on.
- **Consistent error semantics.** Decide the error shape (status codes, error type/enum, message structure) as part of the contract, not as an afterthought once implementation hits an edge case. Match the codebase's existing error convention (from Step 1 evidence) unless there's a stated reason to deviate — log that under Step 3.
- **Validate at the boundary.** Trust drops at a boundary crossing (service-to-service, module-to-module, user input). Input validation belongs at the boundary the untrusted data crosses, not several layers deep where the caller is assumed already-valid.
- **Prefer addition over modification.** When extending an existing contract, design new optional fields/methods rather than changing or removing existing ones. A breaking change to a contract with existing consumers is a deviation — route it through Step 3's Desirable/Undesirable classification, don't let it pass as a silent edit.
- **Predictable naming.** Name new interface members consistently with sibling interfaces already in the codebase (verb/noun conventions, pluralization, casing) — grounded in Step 1 evidence, not personal preference.

## Step 3 — Evaluate Deviations from Convention

Not every convention needs following, but every break needs to be a decision, not an accident. Before writing the plan, classify anything the proposed structure does differently from established convention:

**Desirable** — propose it anyway, with rationale:
- Introduces a better pattern that should eventually replace the old one.
- Breaks a convention that was itself problematic — state why.
- Simplifies a previously over-engineered area.
- Has a clear migration path from old pattern to new.

**Undesirable** — redesign before writing the plan, don't just note it:
- Introduces inconsistency without clear benefit.
- Takes a shortcut that creates technical debt.
- Copies a pattern from a different context that doesn't fit here.
- Makes the "wrong thing easy and the right thing hard" for future changes.

The whole point of doing this before `my-plan` runs is that an undesirable deviation caught here costs a redesign; caught in `my-review` after implementation, it costs a rewrite. Also record alternatives you considered and rejected — they're evidence for Step 6.

## Step 4 — Assess Long-term Impact

Think beyond the immediate change:
- If this pattern is repeated 10 more times, does the architecture get better or worse?
- Does this change make future changes easier or harder?
- Does it increase or decrease cognitive load for someone new to this area?
- Are there scaling implications? (data volume, team size, deployment independence)

## Step 5 — Write the Architecture Plan

Save to `~/.claude/thoughts/shared/architecture/NNN_{descriptive_name}.md` using 3-digit sequential numbering, local to this directory (same convention as `research/`, `specs/`, and `plans/` — each directory keeps its own counter; numbers are not synchronized across artifact types for the same task).

```markdown
---
date: [ISO timestamp]
feature: [Feature/task name]
research: [path to research doc if exists]
spec: [path to clarified spec if exists]
status: proposed
---

# [Feature/Task Name] Architecture Plan

## Summary
[1-2 sentences: what's being built and the architectural shape it will take]

## Current Architecture Context
[Relevant module boundaries, dependency layering, and conventions from Step 1 — with file:line evidence, not assertion]

## Proposed Structural Placement
[Which module(s)/files the change belongs in and why, per the codebase's existing boundary conventions. State plainly: new module, or extend an existing one — and why]

## Dependency & Coupling Design
[New dependency edges this change introduces, their direction, and why they don't violate existing layering. Note anything that increases coupling and whether it's necessary]

## Interface & Contract Design
[Public interfaces/contracts this change introduces or modifies. Keep minimal. Cover error semantics, boundary validation, and addition-vs-modification for any existing contract touched. Note backward-compatibility/versioning if crossing a service boundary. Omit this section if Step 2a did not apply]

## Deviations from Convention

### Desirable
[Intentional departures from existing convention, why each is an improvement, and the migration path if the old pattern should eventually go away]

### Rejected Alternatives
[Approaches considered and rejected because they would have created undesirable inconsistency, debt, or a wrong-thing-easy pattern]

## Long-term Impact
[If this pattern repeats, does the architecture get better or worse? Effect on cognitive load, future changes, scaling]

## Architectural Constraints
[The exact "must not violate" list — dependency directions, module boundaries, naming conventions — mechanically enforceable where possible. Written for `my-plan` to copy directly into its own `## Architectural Constraints` section]
```

## Step 6 — Adversarial Challenge (MANDATORY)

Before presenting the plan, spawn the **adversarial-debate** agent to challenge the proposed structure — the same rigor `my-arch-review`'s Step 6 applies to a diff, applied here to a design instead. Pass:

- The claimed existing conventions and the file:line evidence behind them.
- The proposed structural placement, dependency/coupling design, and interface design.
- The Desirable/Rejected-Alternatives classification from Step 3.

The agent must:
- Verify claimed conventions actually exist in the codebase (not assumed from another project or from memory).
- Steel-man the design choices — "you're introducing this coupling, but is there a simpler placement that avoids it entirely?"
- Challenge the deviation classification — is something classified "desirable" actually just convenient, or is something classified as a needed deviation actually avoidable?
- Check for contradictions — approving a pattern in one section while implicitly relying on its absence elsewhere.
- Verify dependency-direction claims against the actual import graph from Step 1, not the plan's assertion of it.
- When Step 2a applied: challenge whether the contract is genuinely minimal (a Hyrum's-Law audit — does it expose behavior beyond what's meant to be relied on?), whether error semantics match the codebase's existing convention or deviate without justification, and whether an "addition" to an existing contract is actually a breaking change in disguise.

Apply every correction before presenting. Then confirm:
- [ ] Every claimed convention has file:line or pattern-count evidence.
- [ ] Every architectural constraint is concretely falsifiable, not prose-only guidance.
- [ ] Desirable vs. rejected deviations are clearly distinguished with rationale.
- [ ] The proposed placement and dependency design are grounded in Step 1's actual findings, not assumption.
- [ ] If Step 2a applied: the contract is minimal (Hyrum's-Law audit passed), error semantics are stated and justified against existing convention, and no "addition" silently breaks an existing consumer.

## Step 7 — Review and Iterate

Present the plan. Incorporate user feedback on the proposed structure — this is exactly the kind of judgment call (architectural direction, acceptable trade-off) the user owns, not something to self-approve. Update the saved artifact with changes. Once approved, append the artifact path and logged assumptions/decisions only in standalone mode. In embedded mode return the outcome for `my-workflow` to record, including a recommended provisional decision for each genuine trade-off. Recommend `/my-plan`, naming this artifact so it reads the constraints rather than re-deriving them.

## Guidelines

- This is about STRUCTURE, not style — do not flag naming or formatting.
- Respect the existing architecture's intent even where you'd design it differently from scratch.
- A deviation must earn its inconsistency; convention consistency has real value.
- Think in terms of "what does this make easy/hard for the next developer, including whoever implements `my-plan`'s phases?"
- Do not write code or implementation-level phases here — that's `my-plan`'s job. This skill draws boundaries and constraints; it doesn't sequence work.

## References

- `~/.claude/skills/my-arch-review/references/protocol.md` — criteria source of truth (Structural Fit, Coupling, Cohesion, Boundary Integrity, Dependency Health, Desirable/Undesirable Deviations). Read it directly rather than trusting a paraphrase — if it changes, this skill's criteria should track it automatically rather than drift from a stale copy.
- Step 2a's interface/contract principles (Hyrum's Law, contract-first, error semantics, boundary validation, addition-over-modification) live only in this skill — they apply to prospective design, not `my-arch-review`'s retrospective diff criteria.
- `~/.claude/skills/my-plan/references/plan-template.md` — the plan this artifact feeds; its `## Architectural Constraints` section should be seeded from this artifact's, not re-derived.

## Gotchas
If a `gotchas.md` file exists in this skill's directory, read it before starting work. These are known failure patterns — avoid them.

## Output Envelope

Return a compact result, never raw tool or subagent transcripts:

```markdown
status: complete | needs_input | blocked
artifact: { kind: architecture_plan, path: <path> }
summary: <proposed structural placement>
architectural_constraints: [<falsifiable constraint>]
flagged_deviations: [{ deviation, classification, rationale }]
assumptions: [<factual assumption>]
provisional_decisions: [{ question, options, recommendation, evidence }]
external_action_requested: null | { actions, targets, rationale }
```

In embedded workflow mode, resolve factual questions from evidence and return only genuine structural trade-offs as recommended `provisional_decisions`; do not pause for user confirmation. The coordinator owns the Decisions Checkpoint and ledger updates.
