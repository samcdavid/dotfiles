# Tripwire Signals — my-quick

Used by Step 3 of `/my-quick`. If ANY signal fires, STOP and ask whether to escalate to the full `/my-research → /my-spec → ...` pipeline or continue anyway.

Tripwire is conservative by design. False alarms (escalating when it wasn't needed) are cheap. False negatives (proceeding when the change was actually big) are expensive.

## Structural signals

- **New module / new top-level directory** — the change introduces a name that didn't exist before. Architectural review territory; not fast lane.
- **New dependency direction** — module A starts importing module B for the first time. The full pipeline catches the implications.
- **DB migration** — schema change, new column, index change, NOT NULL add. Migration safety belongs in `/my-plan` and `/perf-review`.
- **Cross-service contract change** — public APIs, GraphQL schemas, webhook payloads, channel messages, RPC signatures. Risk lives in the integration, not the diff.
- **LLM prompt / tool-docstring surface** — prompt changes need eval coverage. Skip the fast lane.

## Safety signals

- **Auth / session / token / permission / policy code touched** — security review territory. Run `/security-audit` or `/my-review security` after.
- **Concurrency primitives** — locks, semaphores, transactions, queue ordering. Reasoning is rarely "well-known."
- **External I/O at a new point** — new HTTP call, new file write, new shell-out. The full pipeline catches retry/idempotency concerns.

## Cognitive signals

- **Acceptance criterion can't be stated in one sentence** — if it takes a paragraph to describe what "done" looks like, it's not small.
- **Existing code in scope is unclear** — reading the file once doesn't leave me confident. Research first.
- **The "well-known" claim is recent** — if I just learned this code yesterday, it's not well-known. Research first.
- **Scope creep mid-implementation** — if I find myself thinking "while I'm here, I'll also..." that's a signal. Stop, restart in the full pipeline.

## Volume signals (soft thresholds, not hard caps)

- **More than ~5 files changed** — the diff is getting wide; full pipeline is probably warranted.
- **More than ~200 lines changed total** — same concern.
- **The mini-plan in Step 4 has more than ~3 bullet points** — the change isn't actually small.

Guidelines, not bright lines. Author judgment overrides.

## How to escalate

When tripwire fires, name the signal(s) and recommend the starting skill:

- Structural signal → `/my-research` (understand the system first), then `/my-spec`
- Safety signal → `/my-spec` (write down what success looks like), then `/my-plan`
- Cognitive signal → `/my-research` (build the mental model) or `/my-clarify` (sharpen requirements)
- Volume signal → `/my-plan` (write down the phases), then `/my-implement`

If the user says "continue anyway," respect that. Note the signal and the decision in the Step 8 hand-off summary so it's visible in transcript review.
