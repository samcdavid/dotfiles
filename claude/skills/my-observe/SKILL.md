---
model: opus
name: my-observe
description: "Design observability and monitoring for planned code changes: metrics, traces, spans, logs, dashboards, and actionable alerts."
---

# Observe

Add an observability companion plan for a feature or implementation plan.

## Load Rules

Read `~/.claude/rules/question-policy.md` and `~/.claude/rules/context-checkpoint.md` when available. Use `~/.agents/rules/` under Codex. For platform-specific guidance, read `references/protocol.md`.

## Flow

1. Read the plan/spec and existing observability conventions.
2. Identify user journeys, failure modes, business events, and operational risks.
3. Recommend metrics, traces/spans, logs, dashboards, and alerts.
4. Prefer actionable alerts over noisy symptoms.
5. Save a companion observability plan when working in the workflow.

## Output

Return observability plan path if saved, recommended signals, alert criteria, dashboard ideas, and validation checks.

