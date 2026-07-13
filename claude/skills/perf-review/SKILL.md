---
model: opus
name: perf-review
description: Deep performance review: query plans, index coverage, load impact, caching strategy, resource use, and scaling risks.
---

# Performance Review

Find performance issues that plausibly matter under real load.

## Load Rules

Read `~/.claude/rules/review-finding-format.md` and `~/.claude/rules/pr-mode-readonly.md` when applicable. Use `~/.agents/rules/` under Codex. For full checklist, read `references/protocol-index.md`.

## Flow

1. Identify hot paths, data size assumptions, query surfaces, loops, jobs, requests, caches, and external calls.
2. Read code and tests around changed behavior.
3. Inspect indexes, query shape, batching, concurrency, memory, timeout, and retry behavior.
4. Estimate impact using code evidence, schema, and expected cardinality.
5. Drop theoretical findings without reachable load impact.

## Output

Return findings with path, bottleneck, scale condition, evidence, expected impact, and concrete remediation.

