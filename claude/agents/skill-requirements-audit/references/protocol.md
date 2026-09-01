# Protocol — skill-requirements-audit

The `requirements-audit` wrapper selects the target and requirement source and presents this result. This runner owns routing and evidence assembly; the full traceability checklist remains at `~/.claude/skills/requirements-audit/references/protocol.md` (or `~/.agents/skills/requirements-audit/references/protocol.md` under Codex) because `requirements-reviewer` consumes it directly.

## Dedicated audit flow

1. Resolve the requirements source from the provided spec, plan, ticket, PR body, or linked artifacts. If no source of truth exists after read-only discovery, return `needs_input`; do not invent acceptance criteria.
2. Build the requirements map the retained protocol requires, including explicit criteria and defensible implied edge cases. Normalize the implementation into a fingerprinted PR-safe or local evidence bundle and reuse it under `evidence-bundles.md`.
3. Triage the requirements map against the manifest; dispatch only discovery specialists and `requirements-tracer` whose specific unresolved traceability question meets the retained protocol's review-scope conditions.
4. Dispatch `requirements-reviewer` with the complete bundle, requirements map, and discovery notes. It owns substantive traceability; do not duplicate the shared checklist here.
5. Dedupe and normalize its flat findings. Route every material, high-risk, or uncertain claim to `finding-verifier-high`; route other claims to `finding-verifier-low`, escalating low-tier uncertainty. Dispatch `adversarial-debate` only for surviving coverage, scope, or regression conclusions that involve inference or ambiguity.
6. Render the retained protocol's report shape: requirements map, traceability matrix, Covered/Partial/Missing/Excess/Unclear statuses, test evidence, scope analysis, positive patterns, and dismissed concerns. Never edit, publish, or change remote records.

## Output envelope

```markdown
status: complete | needs_input | blocked
audit: { kind: requirements, target: <target>, mode: <mode> }
requirements_source: <path or ticket>
summary: <verified traceability assessment>
findings: [<verified finding with requirement/code/test evidence and fix>]
dismissed_concerns: [<claim and evidence>]
residual_questions: [<specific missing requirements or behavior evidence>]
external_action_requested: null | { actions, targets, rationale }
```
