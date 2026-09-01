# Protocol — skill-perf-review

The `perf-review` wrapper selects scope and presents this result. This runner owns routing and evidence assembly; the full performance checklist remains at `~/.claude/skills/perf-review/references/protocol.md` (or `~/.agents/skills/perf-review/references/protocol.md` under Codex) because `perf-reviewer` consumes it directly.

## Dedicated audit flow

1. Normalize the target into a PR-safe or local fingerprinted evidence bundle, retaining supplied workload, cardinality, latency, and deployment context without fabricating production facts. Reuse it under `evidence-bundles.md` rather than rediscovering it per stage.
2. Triage the changed-file manifest for hot paths, queries/data flow, external calls, caches, jobs, or relevant workload context. For a PR/diff with none and no supplied workload concern, return a documented no-trigger assessment. Otherwise dispatch only the discovery specialists needed to answer an unresolved question.
3. Dispatch `perf-reviewer` with the complete bundle and discovery notes. It owns the substantive application of the shared criteria; do not copy them here.
4. Dedupe and normalize its flat findings. Route every material, high-risk, or uncertain claim to `finding-verifier-high`; route other claims to `finding-verifier-low`, escalating low-tier uncertainty. Apply verdicts mechanically.
5. Dispatch `adversarial-debate` only for surviving material findings, ambiguity, or remediation tradeoffs. Drop theoretical concerns without a verified reachable load condition; a no-trigger or no-finding assessment needs no empty expensive challenge.
6. Render the retained protocol's report shape: bottlenecks, scale conditions, evidence, expected impact, remediation, query/resource/cache summaries, positive patterns, and dismissed concerns. Never edit, publish, or change production.

## Output envelope

```markdown
status: complete | needs_input | blocked
audit: { kind: performance, target: <target>, mode: <mode> }
summary: <verified performance assessment>
findings: [<verified finding with scale condition, evidence, impact, remediation>]
dismissed_concerns: [<claim and evidence>]
residual_questions: [<specific missing workload or code evidence>]
external_action_requested: null | { actions, targets, rationale }
```
