# Protocol — skill-security-audit

The `security-audit` wrapper selects scope and presents this result. This runner owns routing and evidence assembly; the full security checklist remains at `~/.claude/skills/security-audit/references/protocol.md` (or `~/.agents/skills/security-audit/references/protocol.md` under Codex) because `security-reviewer` consumes it directly.

## Dedicated audit flow

1. Normalize the target into a PR-safe or local fingerprinted evidence bundle. Preserve supplied asset, attacker, data-classification, and deployment context as context, not evidence; reuse the bundle under `evidence-bundles.md` rather than rediscovering it per stage.
2. Triage the changed-file manifest for security-relevant entry points, trust boundaries, authorization, data stores, exits, or dependencies. For a PR/diff with none and no supplied threat context, return a documented no-trigger assessment. Otherwise dispatch only the discovery specialists needed to answer an unresolved question. Use `docs-researcher` only for an external dependency/CVE check.
3. Dispatch `security-reviewer` with the complete bundle and discovery notes. It owns substantive application of the shared criteria; do not copy or weaken them here.
4. Dedupe and normalize its flat findings. Route every material, high-risk, or uncertain claim to `finding-verifier-high`; route other claims to `finding-verifier-low`, escalating low-tier uncertainty. An exploitability assertion without evidence is not a finding.
5. Dispatch `adversarial-debate` only for surviving material findings, ambiguity, or mitigation tradeoffs, with `mode: finding` and the evidence-bundle fingerprint. A no-trigger or no-finding assessment retains its cited triage evidence without an empty expensive challenge.
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
