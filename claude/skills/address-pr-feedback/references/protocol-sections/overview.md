---
model: opus
name: address-pr-feedback
description: Systematically address all pending PR review feedback as a condensed research → plan → implement pipeline. Investigates and triages comments into verified findings, plans test-drivable fixes as small one-fix phases, dispatches each to an isolated implementation-executor (strict TDD), applies non-behavioral trivia directly, then commits with references, drafts evidence-backed responses, and verifies before finishing. Manual invocation only.
disable-model-invocation: true
---

# Address PR Feedback

Systematically work through all pending review feedback on a PR. This skill is a **condensed `my-research` → `my-plan` → `my-implement` pipeline** specialized for reviewer feedback:

- **Act I — Research** (condensed `my-research`): gather every comment and turn it into a **verified, classified finding** — substantiated by code you actually read, challenged adversarially, importance-filtered.
- **Act II — Plan** (condensed `my-plan`): split confirmed fixes into **test-drivable behavioral phases** (sized one fix per phase, with RED tests and mechanical success criteria) versus **non-behavioral direct edits**.
- **Act III — Implement** (condensed `my-implement`): dispatch each behavioral phase to a fresh **`implementation-executor`** subagent (the same agent `my-implement` uses), re-verify each independently, and own loop detection. Apply direct edits yourself.

Then commit with feedback references, draft responses, verify, and publish.

**You orchestrate; the executor implements the behavioral fixes.** You do not write production code or tests for a behavioral fix in the main context — you slice the work, dispatch it, and re-verify what comes back as a skeptical reviewer. The exception is non-behavioral trivia, which you apply directly because it has no honest failing test.
