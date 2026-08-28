---
model: opus
effort: high
name: my-test-strategy
runner: skill-my-test-strategy
description: Design a behavior-first TDD test strategy that maps requirements to durable unit and integration assertions before implementation planning.
---

# Test Strategy

Use `skill-my-test-strategy` for the substantive test-design procedure. This wrapper resolves task and artifact context, preserves the user-facing boundary, and presents the runner's behavior-first TDD strategy.

## Dispatch

Normalize the request into `{ task, artifact_inputs, ledger_path, stage, authority: local_only }` and dispatch it to `skill-my-test-strategy`.

- For a standalone request, derive the task and artifacts from `$ARGUMENTS` and the conversation; leave `stage` unset.
- `my-workflow` invokes the runner's `focused_advisory` mode only when its
  planning conversation needs deeper test design; the binding `TS-*` contracts
  live directly in the workflow ledger.
- If no task or artifact context can be inferred, ask the user for the target behavior or feature.

The runner may create a local test-strategy artifact. In embedded mode it returns the result for `my-workflow` to record; in standalone mode it may append to an existing ledger. It must return any request to create or update remote content, publish, send, push, or deploy for explicit user authorization.

## Present

Return the strategy path, behavior-to-test matrix, TDD handoff, isolation and flakiness controls, plan amendments, assumptions, provisional decisions, and compact decision/artifact envelope.
