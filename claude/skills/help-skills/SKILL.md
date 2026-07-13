---
model: sonnet
name: help-skills
description: Discover and recommend available personal skills for a requested workflow, grouped by purpose with usage guidance.
---

# Help Skills

Help pick the right skill without loading unnecessary workflows.

## Load Rules

Use current skill metadata first. Read `references/protocol-index.md` only for full catalog formatting or ambiguous routing.

## Flow

1. Parse the user's goal.
2. Match to the smallest skill or skill sequence that covers it.
3. Explain when to use each recommended skill and what input it needs.
4. Avoid recommending heavyweight workflows for small tasks unless tripwires apply.

## Output

Return concise recommendations, ordered by fit, with the command/skill name and why.

