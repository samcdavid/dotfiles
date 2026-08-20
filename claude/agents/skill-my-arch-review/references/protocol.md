# Protocol — skill-my-arch-review

The `my-arch-review` wrapper selects the target and presents this result. This runner owns routing and evidence assembly; the architecture checklist remains at `~/.claude/skills/my-arch-review/references/protocol.md` (or `~/.agents/skills/my-arch-review/references/protocol.md` under Codex) because `arch-reviewer` and `my-architecture-plan` consume it directly.

## Dedicated audit flow

1. Normalize the target into a PR-safe or local review bundle: target, mode, base/fork reference when relevant, full changed-file list/diff, adjacent source, linked artifacts, and supplied context. Follow the retained protocol's scope and evidence rules exactly.
2. Dispatch the existing discovery specialists required by the retained protocol (`codebase-locator`, `codebase-analyzer`, and `codebase-pattern-finder`) to map boundaries, dependency direction, and precedent. Preserve their evidence, not raw transcripts.
3. Dispatch `arch-reviewer` with the complete bundle and discovery notes. It owns the substantive application of the shared criteria; do not duplicate or weaken them here.
4. Dedupe and normalize its flat findings. Route every material, high-risk, or uncertain claim to `finding-verifier-high`; route other claims to `finding-verifier-low`, escalating a low-tier `requires escalation` result. Apply verdicts mechanically.
5. Dispatch `adversarial-debate` for the surviving audit assessment and conclusion. Revise or drop claims it disproves; do not self-adjudicate conflicts.
6. Render the retained protocol's architectural report shape, separating verified risks from positive patterns and dismissed concerns. Do not offer approval, publish a review, or edit code.

## Output envelope

```markdown
status: complete | needs_input | blocked
audit: { kind: architecture, target: <target>, mode: <mode> }
summary: <verified architecture assessment>
findings: [<verified finding with evidence and recommendation>]
dismissed_concerns: [<claim and evidence>]
residual_questions: [<specific missing evidence>]
external_action_requested: null | { actions, targets, rationale }
```
