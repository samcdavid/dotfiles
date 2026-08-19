---
model: opus
effort: xhigh
name: my-plan
description: Create a detailed implementation plan with mechanically verifiable success criteria, phase boundaries, tests-first steps, and explicit non-goals.
---

# Create Plan

Turn approved research/spec context into an implementation plan that `my-implement` can execute phase by phase.

## Load Rules

Read:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/tdd-phase.md`
- local `gotchas.md`

Use `~/.agents/rules/` when running through Codex. For complex plans, workflow resumes, or ambiguous scope decisions, read `references/protocol.md`.

## Flow

1. Resolve task from `$ARGUMENTS`, conversation, workflow ledger, research, spec, ticket, or file path.
2. Read existing workflow ledger if present; consume linked research/spec/architecture-plan artifacts before asking questions. If an architecture plan exists, seed `## Architectural Constraints` from it rather than re-deriving constraints independently.
3. Research factual gaps yourself. Pause only for genuine scope, product, or approach decisions.
4. Propose the simplest implementation approach that satisfies the spec, and boundaries. When several approaches would work, default to the one with fewer new abstractions, files, and moving parts — see `references/protocol.md`'s Simplicity Bias.
5. Write ordered phases, each small enough for one executor run.
6. For every behavioral phase include RED tests, GREEN changes, allowed paths, verification commands, and success criteria.
7. For a shared registration, authorization, rollout, or resolver helper, add an explicit contract pass: both allow and deny paths; authenticated identity and argument forwarding; the resolver's membership/ownership responsibility; and composition with required telemetry, session, and context wrappers. Include focused static analysis when typed kwargs or decoded JSON cross a library boundary.
8. State non-goals and risks explicitly.
9. Save plan under `~/.claude/thoughts/shared/plans/`.
10. Append plan path and assumptions/decisions to workflow ledger when present.

## Plan Quality Bar

- Simplest design that satisfies the spec — added complexity (a new abstraction, a new module/service, speculative extensibility) must be justified by a stated requirement, not "might need it later."
- Mechanical success criteria, not prose-only “done.”
- One behavior or small unit per phase.
- Tests first for behavioral changes.
- Shared boundary helpers prove both permitted and denied behavior; tests assert the reached path and relevant side effects, not only an error result.
- Wrapper/decorator helpers preserve mandatory platform contracts (authorization, telemetry, session validation, and context enrichment) or state the concrete composition and its first live-handler test.
- Typed forwarding and deeply decoded test payloads have a focused lint/type-check command in the phase verification.
- Explicit allowed paths and architectural constraints.
- Clear “what we are not doing.”

## Output

Return the plan path, phase summary, decision points, assumptions, and recommended next command.
