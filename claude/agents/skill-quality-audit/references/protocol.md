# Protocol — skill-quality-audit

The `quality-audit` wrapper selects scope and presents this result. This runner owns routing and evidence assembly; the full test-quality checklist remains at `~/.claude/skills/quality-audit/references/protocol.md` (or `~/.agents/skills/quality-audit/references/protocol.md` under Codex) because `quality-reviewer` consumes it directly.

## Dedicated audit flow

1. Normalize the target into a PR-safe or local fingerprinted evidence bundle. Include the relevant plan/spec and tests when supplied; reuse it under `evidence-bundles.md` and follow the retained protocol's scope and evidence rules.
2. Triage the manifest for changed behavior, tests, branches, error paths, fixtures, or mocks. For a PR/diff containing no production or test changes and no supplied test concern, return a documented no-trigger assessment. Otherwise dispatch only the discovery specialists needed to answer an unresolved question.
3. Dispatch `quality-reviewer` with the complete bundle and discovery notes. It owns substantive application of the shared criteria; do not duplicate them here.
4. Dedupe and normalize its flat findings. Route every material, high-risk, or uncertain claim to `finding-verifier-high`; route other claims to `finding-verifier-low`, escalating low-tier uncertainty. A missing test only survives if a realistic bug can escape.
5. Dispatch `adversarial-debate` only for surviving material test-fidelity/coverage conclusions or ambiguity. Apply independent verdicts mechanically; a no-trigger or no-finding assessment needs no empty expensive challenge.
6. Render the retained protocol's report shape: coverage matrix, fidelity/escape path, flakiness and mock-risk assessment, stronger-test recommendation, positive patterns, and dismissed concerns. Never edit, publish, or change a test suite.

## Output envelope

```markdown
status: complete | needs_input | blocked
audit: { kind: quality, target: <target>, mode: <mode> }
summary: <verified test-quality assessment>
findings: [<verified finding with code/test evidence, escape path, stronger test>]
dismissed_concerns: [<claim and evidence>]
residual_questions: [<specific missing test or behavior evidence>]
external_action_requested: null | { actions, targets, rationale }
```
