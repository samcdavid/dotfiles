---
model: opus
effort: xhigh
name: my-investigate
description: Investigate production, runtime, CI, or test issues by gathering evidence from logs, metrics, traces, code, and CI, then ranking hypotheses.
disable-model-invocation: false
---

# Investigate

Coordinate a read-only runtime or CI investigation.

## Load Rules

Read `~/.claude/rules/question-policy.md`, `~/.claude/rules/no-outward-actions.md`, and `~/.claude/rules/model-escalation.md` when available. Use `~/.agents/rules/` under Codex. For full investigation procedure, read `references/protocol.md`.

## Flow

1. Capture symptom, time range, affected service, artifacts, and user blast-radius hint.
2. Load Datadog/CircleCI skills before their tools when applicable.
3. Dispatch `runtime-investigator` with a structured bundle.
4. Review evidence, ranked hypotheses, and targeted questions.
5. Ask the user only for context tools cannot provide.
6. Do not mitigate or change infrastructure without explicit request.

## Output

Return investigation summary, evidence, timeline, blast radius, ranked hypotheses, targeted questions, and read-only next checks.

