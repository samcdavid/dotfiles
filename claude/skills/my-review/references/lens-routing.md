# Lens Routing

Load this before spawning review subagents.

Activate lenses by changed surface:

- Security: auth, authz, input handling, secrets, tokens, file upload, external credentials.
- Architecture: new modules, dependency direction, boundary shifts, abstractions, service design.
- Performance: queries, hot paths, caching, jobs, loops, fan-out, lock/contention risk.
- QA: changed tests, missing tests, fixtures, mocks, async behavior, assertion fidelity.
- Requirements: linked ticket, spec, acceptance criteria, product-facing behavior.
- General reviewer: backend, frontend, full-stack, ops, migration, dependency changes.

Run research agents only for unanswered facts. Then send the full aggregate
diff, compact notes, and all activated coverage criteria to the one
whole-diff `general-reviewer`; lenses are checklists, not default subagents.
