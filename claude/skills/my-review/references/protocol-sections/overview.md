---
model: opus
name: my-review
description: Rigorous code review modeled on OSS standards. Reviews local changes or GitHub PRs for correctness, cross-service contracts, idempotency, test fidelity, and performance. De-duplicates against existing review comments. Orchestrates parallel research subagents and specialized per-lens reviewer subagents, then compiles, adversarially challenges, and renders the verdict in the main conversation.
---

# Code Review

Perform a thorough, high-quality code review. Works on local changes (unstaged/staged/committed) or GitHub pull requests.

This skill is the **orchestrator**. It fans the work out to subagents — parallel research subagents for deep context, then specialized per-lens reviewer subagents (security, architecture, performance, QA, requirements, and a general reviewer for the rest) — and then does the parts that genuinely need the main window: triage, merging and de-duplicating the lens findings, targeted questions, the adversarial passes, the verdict, and pattern capture. The deep per-lens reasoning happens in the subagents; the judgment and synthesis happen here.
