---
model: opus
effort: xhigh
name: my-research
description: Deep codebase research with verified findings. Uses focused discovery agents, cross-checks claims against code, saves a durable research artifact, and records assumptions.
---

# Research Codebase

Answer the research question with verified, code-grounded findings. External docs, tickets, and notes are starting points, not substitutes for reading code.

## Load Rules

Read these first:

- `~/.claude/rules/question-policy.md`
- `~/.claude/rules/context-checkpoint.md`
- `~/.claude/rules/subagent-contract.md`

If running through Codex, use `~/.agents/rules/`.

For complex investigations, Datadog/Braintrust searches, or workflow-stage runs, read `references/protocol.md` and any local `gotchas.md`.

## Flow

1. Determine the research question from `$ARGUMENTS`, the conversation, a linked ticket, or a workflow ledger. Do not ask a blank intake question when context is available.
2. Read explicit files, tickets, plans, specs, and ledgers first.
3. Discover relevant code with focused agents:
   - `codebase-locator` for locations only.
   - `codebase-analyzer` for deep implementation reading.
   - `codebase-pattern-finder` for conventions and similar implementations.
   - `requirements-tracer` only for change-impact or regression-risk questions.
4. Search Linear, Notion, Google Drive, and prior thought artifacts when product intent or prior decisions may live there. For Drive, prefer an installed, authenticated `gws` CLI and fall back to Google Drive MCP only when the CLI is unavailable or unusable.
5. Resolve contradictions by reading primary code or source artifacts.
6. Run adversarial challenge before finalizing.
7. Save a research document in `~/.claude/thoughts/shared/research/NNN_topic.md`.
8. If a workflow ledger exists, append the research artifact path and factual assumptions.

## Research Artifact

Include:

- Research question
- Executive summary
- Detailed findings with file:line evidence
- Architecture or data-flow notes
- Files and external artifacts examined
- Open questions or remaining uncertainty

## Output

Return a concise summary and the research artifact path. Do not present unverified claims as findings.
