---
model: opus
name: implement-conversation
description: Conversation-to-code pipeline for changes described in chat. Runs my-research → pipeline gate → quick-plan/quick-implement (for refactors and targeted fixes) or my-plan/my-implement (for new behavior and complex changes) → my-review. Autonomous after intake.
disable-model-invocation: true
---

# Implement Conversation

Turn a conversational change request into implemented, reviewed code. This skill runs the right-sized pipeline for the change — research, plan, implement, review — without the full 9-stage delivery overhead of `my-workflow`.

**When to use this vs. `my-workflow`:** Use this skill when you've described what you want in chat — a targeted fix, refactor, rename, cleanup, or small addition — and want it executed rigorously rather than one-shot inline. Use `my-workflow` for substantial feature delivery that warrants spec, clarify, observe, analyze, and validate stages.
