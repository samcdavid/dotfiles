---
model: opus
effort: xhigh
name: my-architecture-plan
description: Plan the architectural shape of a change before implementation — module placement, coupling and cohesion, boundary and dependency design, and any deliberate deviation from convention — so my-plan's phases and my-implement's code land in the right structure the first time.
---

# Architecture Plan

Design where and how a change should fit into the existing system, before `my-plan` writes phases and before any code exists. Reuses `my-arch-review`'s criteria — Structural Fit, Coupling, Cohesion, Boundary Integrity, Dependency Health — applied prospectively as design decisions instead of retrospectively as review judgments. When the change adds or touches a public interface, also applies contract-first design principles (Hyrum's Law, consistent error semantics, boundary validation, addition-over-modification, predictable naming).

## Load Rules

Read:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`

Use `~/.agents/rules/` when running through Codex. For the full flow, the criteria source, the artifact template, and the adversarial-challenge step, read `references/protocol.md`.

## Flow

1. Resolve task from `$ARGUMENTS`, conversation, workflow ledger, research, spec, clarify output, or file path.
2. Read the workflow ledger (if present) and consume linked research/spec/clarify artifacts by path before asking questions.
3. Learn the existing architecture: module boundaries, dependency directions, and established conventions (`codebase-locator`/`codebase-analyzer`/`codebase-pattern-finder`, same discovery `my-arch-review` runs).
4. Apply `my-arch-review`'s five criteria categories to the *planned* change — decide where it belongs and how it should be shaped, not just critique a diff that doesn't exist yet.
5. If the change adds or touches a public interface, apply contract-first design (Hyrum's Law, error semantics, boundary validation, addition-over-modification, predictable naming) before moving on.
6. Flag any deliberate deviation from convention, with rationale, before code is written — this is the cheapest point to catch an undesirable one.
7. Assess long-term impact of the proposed structure if the pattern is repeated.
8. Write the architecture plan; save under `~/.claude/thoughts/shared/architecture/`.
9. Append the artifact path and any assumptions/decisions to the workflow ledger when present.

## Architecture Plan Quality Bar

- Every claimed existing convention is backed by actual code evidence (file:line or pattern count), not assumed.
- Every constraint is concretely falsifiable — a reviewer or `my-implement` phase can point at a violation — not vague guidance.
- Deviations from convention are explicit and justified, never silent.
- The `## Architectural Constraints` section is written so `my-plan` can carry it into its own plan verbatim, not re-derive it.

## Output

Return the architecture-plan path, the proposed structural placement in one paragraph, the key constraints, any flagged deviations, and the recommended next command (`/my-plan`, pointing at this artifact).
