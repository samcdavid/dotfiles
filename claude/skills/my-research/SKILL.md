---
name: my-research
description: Deep codebase research with verified findings. Spawns parallel agents to explore, then cross-references all claims before presenting results. Use when you need to understand how something works before making changes.
disable-model-invocation: true
---

# Research Codebase

Conduct comprehensive, VERIFIED codebase research. Every finding must be substantiated by code you actually read.

## Getting Started

Respond: "Ready to research. What's your question or topic?"

Wait for the user's research query before proceeding.

## Step 1 — Read Explicit Context

If the user mentions specific files, read them FULLY first (no limit/offset). This grounds your understanding before broader exploration.

## Step 2 — Decompose the Research Question

Break the question into composable research areas. For each area, identify:
- What files/components are likely involved
- What questions need answering
- What would constitute a COMPLETE answer

## Step 3 — Parallel Discovery

Spawn parallel sub-agent tasks to explore the codebase:
- **codebase-locator**: Find all relevant files and directories
- **codebase-analyzer**: Deep-read key implementations
- **codebase-pattern-finder**: Find related patterns and conventions

Wait for ALL sub-agents to complete before proceeding.

## Step 4 — Synthesize Findings

Combine sub-agent results into a coherent picture. Resolve any contradictions — if agents report conflicting information, investigate until resolved.

## Step 5 — Verification Gate (MANDATORY)

Before finalizing, verify EVERY finding against this checklist:

- [ ] Every file path referenced actually exists (glob to confirm)
- [ ] Every code snippet quoted matches current code (read to confirm)
- [ ] Every architectural claim is supported by code evidence
- [ ] No contradictory findings left unresolved
- [ ] The research question is fully addressed
- [ ] Open questions are explicitly noted (not silently skipped)

If any check fails, correct the finding before proceeding. Do NOT present unverified claims.

## Step 6 — Save Research Document

Save to `~/.claude/thoughts/shared/research/NNN_topic.md` using 3-digit sequential numbering.

Format:
```markdown
---
date: [ISO timestamp]
topic: [Research topic]
tags: [relevant, tags]
status: complete
---

# Research: [Topic]

## Research Question
[The original question]

## Summary
[2-3 paragraph executive summary]

## Detailed Findings

### [Component/Area 1]
[Findings with file:line references]

### [Component/Area 2]
...

## Architecture Insights
[How components relate, data flow, key boundaries]

## Code References
[Index of all files examined]

## Open Questions
[Anything that remains unclear — be explicit]
```

Present the summary to the user and provide the file path.
