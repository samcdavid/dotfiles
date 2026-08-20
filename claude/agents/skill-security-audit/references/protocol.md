# Protocol — skill-security-audit

The `security-audit` wrapper selects scope and presents this result. This runner owns routing and evidence assembly; the full security checklist remains at `~/.claude/skills/security-audit/references/protocol.md` (or `~/.agents/skills/security-audit/references/protocol.md` under Codex) because `security-reviewer` consumes it directly.

## Dedicated audit flow

1. Normalize the target into a PR-safe or local review bundle. Preserve supplied asset, attacker, data-classification, and deployment context as context, not evidence. Follow the retained protocol's scope and evidence rules.
2. Dispatch the retained protocol's discovery specialists to map entry points, trust boundaries, authorization, data stores, exits, dependencies, and relevant precedent. Use `docs-researcher` only when the retained protocol requires an external dependency/CVE check.
3. Dispatch `security-reviewer` with the complete bundle and discovery notes. It owns substantive application of the shared criteria; do not copy or weaken them here.
4. Dedupe and normalize its flat findings. Route every material, high-risk, or uncertain claim to `finding-verifier-high`; route other claims to `finding-verifier-low`, escalating low-tier uncertainty. An exploitability assertion without evidence is not a finding.
5. Dispatch `adversarial-debate` for the surviving assessment and mitigation recommendations. Apply the independent verdicts instead of resolving disagreement by confidence alone.
6. Render the retained protocol's report shape: affected asset/data, attacker or misuse path, evidence, impact, mitigation, dependencies, positive patterns, and dismissed concerns. Never exploit, edit, publish, or change production.

## Output envelope

```markdown
status: complete | needs_input | blocked
audit: { kind: security, target: <target>, mode: <mode> }
summary: <verified security assessment>
findings: [<verified finding with asset, path, evidence, impact, mitigation>]
dismissed_concerns: [<claim and evidence>]
residual_questions: [<specific missing code, environment, or dependency evidence>]
external_action_requested: null | { actions, targets, rationale }
```
