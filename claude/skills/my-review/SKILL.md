---
effort: xhigh
name: my-review
description: "Rigorous code review for local diffs or GitHub PRs. Uses a high bar for REQUEST_CHANGES: only Critical merge-blocking issues should block a PR; approve only when requirements are satisfied."
when_to_use: "Use when the user asks to review their changes, diff, branch, or a GitHub PR."
---

# Code Review

Review local changes, branches, or GitHub PRs for correctness, requirements coverage, security, architecture, performance, operations, migration safety, dependencies, test quality, and unnecessary complexity.

## Merge-Blocking Bar

In GitHub, `REQUEST_CHANGES` blocks merge. Use it only for **Critical** findings:

- likely production or core workflow breakage
- data loss, corruption, or exposure
- exploitable security/privacy risk
- likely runtime break in a cross-service/API/persistence contract
- omitted must-have acceptance criterion that makes the feature objectively incomplete

Important does not automatically mean merge-blocking. Non-Critical findings may still make the right GitHub verdict `COMMENT` rather than `APPROVE` when they are substantive or numerous.

## Approval Bar

Approve only when the PR satisfies the stated requirements and no Critical findings survive review.

- Use `COMMENT` when there are several substantive inline comments, unresolved requirements questions, or enough non-blocking concerns that approval would overstate confidence.
- Use `APPROVE` when requirements are satisfied and only minor nits or clearly optional suggestions remain.
- Use `REQUEST_CHANGES` only for Critical findings.

## Load Rules

Read first:

- `~/.claude/rules/review-finding-format.md`
- `~/.claude/rules/subagent-contract.md`
- `~/.claude/rules/model-escalation.md`
- `~/.claude/rules/no-outward-actions.md`

If reviewing a PR, also read:

- `~/.claude/rules/pr-mode-readonly.md`
- `~/.claude/rules/pr-cost-control.md`

Under Codex, use the same files under `~/.agents/rules/`.

Load targeted references as needed:

- `references/mode-routing.md` when choosing local, branch, PR, capture, or promote mode.
- `references/pr-mode.md` for GitHub PR reviews.
- `references/lens-routing.md` before spawning research and lens reviewers.
- `references/project-context.md` when a linked or explicitly supplied Linear issue has a project; it defines the bounded project-context and duplicate-follow-up check.
- `references/finding-axes.md` before spawning lens reviewers and again before routing findings to verifiers — it defines severity, risk, and confidence, and the tier rule.
- `references/finding-finalization.md` before presenting findings.

For learned-miss maintenance, read `references/learned-misses.md` (active queue) and `references/promoted-misses.md` (promoted/discarded archive). Always read local `gotchas.md` when present.

## Flow

1. Determine mode: capture/promote, PR, branch/range, local, or local issue (a local branch review associated with an explicitly supplied Linear issue).
2. Build the diff source of truth. In PR mode, use filtered GitHub payloads from `pr-cost-control.md`. In local mode the scope is the **whole branch** — `git diff $(git merge-base <base_ref> HEAD)`, covering every commit since the base branch plus staged and unstaged changes. Never the last commit alone, never the working tree alone.
3. Identify active lenses and requirements source.
4. Fan out research agents, then active lens reviewers.
5. Merge and dedupe the lens reviewers' flat findings, preserving each one's severity, risk, and confidence.
6. Verify **every** finding independently — one verifier dispatch per finding, in parallel, never batched. The three levels pick the tier: `finding-verifier-high` (Opus) for Critical, High risk, or low-confidence non-trivial claims; `finding-verifier-low` (Sonnet) for the rest. Re-dispatch any low-tier `requires escalation` to the high tier.
7. Compute the verdict mechanically from the findings that survive as Critical, then adversarially challenge only the remaining APPROVE/COMMENT choice.
8. Return findings and verdict. Do not edit code or publish review unless explicitly asked.

## Output

Findings first, ordered by severity, with file:line evidence and concrete fixes. Include targeted questions, residual risk, coverage summary, and verdict.

For PRs: use `REQUEST_CHANGES` only for Critical findings. Use `APPROVE` only when the change satisfies requirements; use `COMMENT` for several substantive inline comments or unresolved non-blocking concerns.
