# Skills and Agents Changelog

Use this as the curated history of behavior-changing work in `claude/skills/`,
`claude/agents/`, shared rules, and generated Codex agents. It is not a raw
`git log`: each entry marks a useful regression boundary.

## How to use it

When a skill regresses, start with the newest matching entry, inspect its diff,
then compare it with the prior known-good anchor:

```bash
git show <commit>
git diff <known-good>..<suspect> -- claude/skills claude/agents claude/rules codex/agents
git revert <commit> # only when reverting the whole recorded change is correct
```

Do not hand-edit `codex/agents/*.toml`; change canonical agent Markdown, run
`scripts/sync-codex-agents`, then record the behavior change below.

## 2026-08-20 — Cross-runtime runners and model routing

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `98bc890` | Refined `team-plan` for demoable MVP milestones and very small reviewable issue slices, and moved its substantive planning into `skill-team-plan` (Sol/xhigh). | Every functional milestone must have a stakeholder demo path; implementation issues target a few tightly related changes and a 30-minute pickup-to-finished-review cycle, while the wrapper retains Linear coordination, approval, and writes. |
| `1941829` | Calibrated `my-review` for default-off, per-user Eppo rollout gates. | Treat an entitlement-gated rollout as an intended cohort boundary; evaluate concrete enabled-cohort behavior and reserve merge blocks for immediate policy violations or harm. |
| `7851ecc` | Scoped PR review and publication to the aggregate merge-base-to-HEAD diff. | Reviewers may use unchanged code as context, but every finding needs a changed-line causal link; baseline-only defects and out-of-diff findings are withheld rather than converted to PR-level comments. |
| `bf2c6c0` | Added an evidence-backed, collapsed implementation-decisions section to `create-pr` descriptions. | PR bodies must source recorded choices from the branch workflow ledger and implementation artifacts, preserve outcomes and rationale, and say when no record exists rather than infer intent from the diff. |
| `340d41a` | Added `my-test-strategy` and made behavior-first TDD planning a gated `my-workflow` stage. | Full workflows must create a behavior-to-test strategy before `my-plan`; embedded implementation requires its observable contracts and isolation controls, and review rejects tests coupled to queries, call sequences, or supervisor mechanics. |
| `229bbc5` | Routed `team-plan` through named spec, research, architecture, and adversarial runners. | Keep team-plan coordination on the caller model while `skill-my-research` supplies Sol/xhigh verified gap research, architecture routing applies to structural projects, and Sol/xhigh challenges the final Linear draft. |
| `6ad33b8` | Expanded `team-plan` from milestone sequencing into project discovery, codebase-gap research, job stories, PR-backed issue design, and approval-gated Linear creation. | Team plans must trace requirements through researched gaps to one-PR issues, isolate Ecto migration-only work from functional delivery, and target six to eight safe parallel issues when scope permits. |
| `922d52f` | Added pinned runners for investigation and audit skills. | `my-investigate` is Sol/xhigh; security/perf are Sol/high; other audit orchestration is Terra/high. Shared audit criteria stay under skills for lens-agent consumers. |
| `7579906` | Added delivery-stage runners. | `my-implement`, `my-validate`, and `my-review` delegate execution; review remains a Terra/high mechanical router over specialized reviewers. |
| `e4afd3d` | Added planning-stage runners. | Architecture, planning, and analysis use Sol/high; observe/eval use Terra/high. |
| `50e9911` | Added research/spec/clarify runners. | Research is Sol/xhigh; spec and clarification are Terra/high. |
| `8f3f46a` | Refactored PR-feedback runner and workflow routing. | PR feedback is Terra/high and owns the capped local repair loop; the wrapper keeps PR/outward-action authorization. `my-workflow` is the skill-only coordinator. |
| `f0ac60d` | Added lifecycle runners. | `start-day` is Terra/high; `end-day` and `pulse` are Terra/medium. |
| `37a2027` | Added recursive runner-resource drift checks. | Runner references, citations, and the Claude agents home link are checked. |
| `2bb94a6` | Added reciprocal wrapper/runner validation. | A declared runner must have matching `runner-for`, model, effort, and Codex model metadata. |
| `44c3826` | Pinned all pre-existing Codex agents. | Canonical agent frontmatter controls both Claude and generated Codex model selection. |

## 2026-08 — Workflow, review, and safety hardening

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `b1ad3fa` | Required idempotent migration creates during review. | Review should reject unsafe repeatable migration creation. |
| `c6531ef` | Added migration-safety workflow gate. | Migration work must follow the full workflow and pass explicit history/compatibility validation. |
| `e540c65` | Strengthened planning and review guardrails. | Planning/review must preserve explicit constraints and verification discipline. |
| `7e32377` | Documented review workflow corrections. | Use as the boundary for recent review-process fixes. |
| `89d9c52` | Standardized Terra/Sol model names for verifier tiers. | High/low finding-verifier routing remains model-distinct. |
| `a5f83d2` | Made verification per finding. | `my-review` must dispatch one verifier per finding, with high-tier escalation when needed. |
| `5c01dd8` | Added PROMOTE handling and per-finding verification. | Review verdict handling includes evidence-based promotion, not only downgrade/drop. |
| `e7ea05c` | Collapsed PR-feedback approvals to a single triage gate. | Once PR triage is confirmed, the authorized flow may continue; local mode never publishes. |
| `118399d` | Added one workflow Decisions Checkpoint. | Stages 1–8 run together, then stop for confirmation before implementation. |

## 2026-07 — Protocol and operational conventions

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `d634c94` | Added `my-architecture-plan` before `my-plan`. | Full workflow architecture planning precedes implementation planning. |
| `84df01d` | Flattened skill protocols and standardized frontmatter. | A single protocol reference is the normal long-form instruction location. |
| `91fd8b4` | Enforced read-only agents and phase commits. | Read-only has explicit deny lists; validated implementation phases commit locally through `commit`. |
| `5ce12ab` | Documented canonical skills/agents and Codex sync conventions. | Treat `claude/` as source and generated Codex TOML as derived. |
| `53d2168` | Allowed local commits and preferred effort over model pins. | Remote action remains gated, while local verified work is committed. |

## 2026-06 to 2026-05 — Delivery pipeline foundations

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `e43123b` | Refactored into orchestrators, executors, and review lenses. | Behavioral work uses `implementation-executor`; reviews use specialized lenses. |
| `c619e88` | Made RED → GREEN → VALIDATE mandatory. | Plans and implementation phases require an honest failing test before the fix. |
| `60cae59` | Moved investigation evidence gathering to `runtime-investigator`. | Investigation delegates evidence gathering instead of relying on main-context guesses. |
| `f5e0e7f` | Moved pulse gathering/synthesis to `pulse-aggregator`. | Pulse wrapper is thin; aggregator owns the briefing. |
| `786224e` | Moved autoresearch iterations to an agent. | The skill owns the outer loop; one agent owns each atomic experiment. |
| `a0a0433` | Introduced `my-workflow`. | Use this as the first full-pipeline orchestration anchor. |
| `a269cd5` | Introduced per-skill/per-agent model selection. | Historical starting point for model-routing regressions. |

## 2026-03 — Initial skills baseline

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `fe638ab` | Added initial Claude global config, skills, and agents. | Earliest baseline for the original research/plan/implement/review toolset. |
| `4d28106` | Added `gotcha`, `careful`, and `freeze`. | These remain skill-level safety hooks; do not replace their parent-session behavior with a detached agent. |

## Maintaining this file

Add an entry for any user-visible behavior, safety boundary, workflow order,
model-routing, agent-contract, or generated-Codex change. Include the local
commit SHA, a short behavior summary, and the known-good boundary it creates.
Skip typo-only or formatting-only edits.
