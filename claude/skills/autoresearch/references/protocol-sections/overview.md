---
model: sonnet
name: autoresearch
description: Autonomous goal-directed iteration loop. Modify, verify mechanically, keep or rollback, repeat. Runs until interrupted or iteration limit reached. Invoke manually when you want to iterate on a measurable goal (tests, benchmarks, coverage, build size, etc). Optional iteration limit as argument (e.g. /autoresearch 100). Delegates each iteration's work to the `autoresearch-iteration` agent so the main loop holds only structured results.
disable-model-invocation: true
---

# Autoresearch — Autonomous Goal-Directed Iteration

Inspired by Karpathy's autoresearch. Constraint-driven autonomous iteration: modify, verify, keep/discard, repeat. The main loop owns control, the results log, and limit checking; each iteration's read-modify-verify work runs inside the `autoresearch-iteration` agent so the main window stays small even across long runs.
