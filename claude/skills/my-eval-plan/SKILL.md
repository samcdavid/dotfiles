---
model: opus
name: my-eval-plan
description: Design evaluation plans for AI/LLM features: datasets, scorers, baselines, success criteria, and regression strategy.
---

# Eval Plan

Design a practical evaluation strategy before or alongside AI feature work.

## Load Rules

Read `~/.claude/rules/question-policy.md` when available. Use `~/.agents/rules/` under Codex. For full planning procedure, read `references/protocol-index.md`.

## Flow

1. Identify feature behavior, failure modes, users, and quality bar.
2. Define eval dimensions and scorer types.
3. Propose dataset sources, golden examples, adversarial cases, and holdout strategy.
4. Set baseline and launch thresholds.
5. Specify regression cadence and review process.
6. Keep platform-agnostic unless the repo already uses a specific eval tool.

## Output

Return scorer definitions, dataset plan, baseline targets, instrumentation needs, and implementation checklist.

