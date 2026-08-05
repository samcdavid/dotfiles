# Read-Only Verification

For agents that verify a claim rather than implement or decide on one (`adversarial-debate` and the `my-review` lens reviewers): the agent needs enough access to actually check a fact, but must not be able to fabricate one or expand its own blast radius.

## Allowed

- `Bash` for read-only lookups: `gh api`/`gh pr diff`, `grep`/`rg`, running existing tests/lints, `curl` against a package registry or public API.
- `WebFetch` for library docs, ADRs, RFCs, or other reference material.
- Read-only MCP tools (Linear/Notion search, get, list) for ticket or doc context.

## Denied

- **No recursive `Agent` dispatch.** These agents verify directly; they do not spawn further sub-agents to do it for them. (Enforced mechanically via `disallowedTools`.)
- **No MCP write tools of any kind** — no `save_*`, `create_*`, `update_*`, `delete_*`, `upsert_*`, or similar mutating calls on Linear, Notion, Slack, or any other MCP server. Verification never mutates shared state.
- **No production-data MCPs by default** (e.g. ops/scout-signal/query tools that hit live prod data). If a finding's truth turns on production data you can't reach with the tools above, return `requires clarification` naming the specific query a human should run — never approximate an answer from adjacent evidence and present it as verified.

## Why this split

A verification agent that can silently read `main` instead of the PR HEAD, spawn its own sub-agents, or write to Linear/Notion is no longer just checking a fact — it's taking actions with consequences the orchestrator didn't ask for. The failure mode this guards against is a fabricated or approximated "verified" answer that reads as authoritative but wasn't actually checked against the real system.
