---
model: sonnet
name: my-quick
description: One-pass implement for small, well-known changes. Collapses the my-research → my-spec → my-clarify → my-plan → my-analyze → my-implement → my-validate → my-review flow into a single lightweight pass with full TDD discipline. Trips out and asks before continuing when signals suggest the change isn't actually small. Stops after self-review — does not commit or push.
---

# Quick — One-Pass Implement

For changes I already understand, where running the full 8-skill pipeline would be ceremony. Implements with full TDD discipline, runs mechanical checks, and does a quick self-review — but skips spec/plan/analysis artifact generation, parallel research agents, and a separate review pass.
