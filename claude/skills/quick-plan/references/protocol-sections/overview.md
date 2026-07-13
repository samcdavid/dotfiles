---
model: opus
name: quick-plan
description: Lightweight conversation-driven planning. Applies a TDD gate per phase — pure refactors get direct-edit phases (no RED/GREEN); behavior-changing fixes get TDD phases. One function per phase regardless. Produces a plan file consumed by quick-implement.
---

# Quick Plan

Create a lightweight plan for a conversation-driven change. Unlike `my-plan`, this skips the full interactive discovery loop — the change is understood from the conversation context. The plan focuses on phasing the work correctly and classifying each phase with the TDD gate.

This skill is typically invoked by `implement-conversation`, which has already run `my-research` and determined the quick pipeline is appropriate.
