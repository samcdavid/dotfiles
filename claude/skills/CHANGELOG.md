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

## 2026-09-01 — Bounded edit delegation across workflows

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `9145961` | Routed five additional edit-capable workflows through `my-implement` and removed the autoresearch iteration agent. | `my-quick`, `ci-babysit`, `update-deps`, and `my-validate` keep their judgment and independently verify one bounded Haiku-delegated edit. `autoresearch` retains metric-based keep/discard control and commits only accepted experiments. |

## 2026-09-01 — CLI-delegated implementation

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `9fe5b7e` | Made `my-implement` the direct orchestrator and removed its runner, TDD executor, and direct-edit executor agents. | Every bounded implementation or repair edit is delegated sequentially with `claude --model haiku --no-chrome --strict-mcp-config -p "<task to complete>"`, independently verified, and locally committed only after validation. `address-pr-feedback` and `implement-review` invoke `my-implement` for their edits. |

## 2026-09-01 — High-capability model routing

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `2ffc51c` | Restricted Opus/Sol routing to `my-review`'s high-judgment review dependencies. | Every other skill uses Sonnet and every other pinned Codex agent uses Terra; their declared reasoning effort is unchanged. `adversarial-debate`, architecture/security/performance reviewers, and `finding-verifier-high` retain Opus/Sol because `my-review` dispatches them. |

## 2026-08-28 — Local migration validation boundary

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `4167342` | Kept staging migration evidence out of local `my-workflow` review. | Local implementation validation runs the repository's normal migration command and tests. Staging migration artifacts and physical-schema evidence remain a later deployment gate because they cannot exist before a PR and staging deployment. |

## 2026-08-28 — Review acknowledgements for test changes

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `ce15da6` | Renamed `my-review` human-review handoffs to human acknowledgements and added modified existing tests to the trigger set. | Environment, flag, migration, config, infrastructure, suppression, and pre-existing-test changes appear in one deduplicated acknowledgement item. Test files trigger only when they existed at the comparison base; brand-new tests do not. A test acknowledgement remains separate from defect analysis and operational confirmation, while local code verdicts and PR readiness gates retain their existing behavior. |

## 2026-08-28 — Local pre-stage review verdicts

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `d4a8325` | Separated local code approval from pre-stage human readiness checks in `my-review`. | Local, branch, issue, and embedded reviews always say whether the code itself is `APPROVE` or `REQUEST_CHANGES`. Environment-variable, feature-flag, migration, config, infrastructure, and suppression items remain visible as a separate pre-stage checklist but cannot suppress the code verdict; PR operational-readiness confirmation continues to gate PR approval. |

## 2026-08-28 — Incremental review scope

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `a7755c2` | Allowed `my-review` to approve coherent incremental and non-user-facing delivery. | Review resolves the concrete outcome promised by the current change and classifies eventual-feature requirements as included now, supporting groundwork, deferred, or unclear. Internal foundation work and teammate handoffs do not block approval merely because final integration remains, while falsely claimed outcomes, unsafe partial boundaries, reachable breakage, regressions, and unresolved consequential scope still receive findings or a plain-language question. |

## 2026-08-28 — Code context in pairing conversations

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `c4deb83` | Required every `my-pair-plan` decision, question, or active design discussion to include its relevant code context. | Before prompting the user, pairing rereads the source and shows the smallest complete current excerpt with a clickable file/start-line, language fence, and explanation of what matters. When no implementation exists, it shows a clearly labeled proposed interface or pseudocode sketch instead of asking an abstract question or presenting invented code as current. |

## 2026-08-28 — Human-readable skill output

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `8d36cba` | Required workflow skills and agents to explain internal references in plain language. | User-facing questions and reports lead with the actual requirement, decision, test outcome, phase result, finding/problem/fix, or commit effect. Stable IDs such as `A-003`, `IR-67`, `R-4`, test IDs, finding keys, phase numbers, and SHAs remain available only as optional traceability metadata after their meaning; agents return both ID and description so wrappers never ask users to decode bookkeeping. |

## 2026-08-28 — Outcome-only testing

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `e49ea68` | Required planning, implementation, and review to derive tests only from distinct desired outcomes. | Each outcome receives one smallest proving test. Returned values, public errors, user-visible behavior, persisted state, and explicitly requested external effects are valid assertions; telemetry, database/cache access, locks/semaphores, collaborator calls, retries, call order, and framework mechanics are handled as non-test constraints unless explicitly defined as the product outcome. Duplicate coverage of the same outcome across layers is rejected. |

## 2026-08-28 — Collaborative workflow planning

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `d7b88b3` | Replaced `my-workflow`'s serial pre-implementation artifact pipeline with `my-pair-plan` and one living issue ledger. | Full workflows read the current issue plus the deterministic linked/milestone/project sibling corpus, briefly orient in code, pair through one recommended decision at a time, and call existing specialist agents only for focused deep dives. Explicit ledger synchronization is followed by a fresh current-version preflight and separate current-version implementation authorization; `my-implement` and `implement-review` retain their existing execution and review loops. |

## 2026-08-28 — Operational readiness review gate

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `2cafa03` | Required human readiness confirmation for environment variables, feature flags, and migrations before review approval. | Review still analyzes the full diff and keeps the handoff separate from defect risk, but returns approval pending until a human confirms appropriate env/flag values in every staging and production environment and successful staging migration/backfill testing. Advisory config/infra/suppression acknowledgements remain separate and cannot satisfy this gate. |

## 2026-08-27 — Post-implementation review loop

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `ba54e5c` | Separated full plan implementation from the bounded review/repair loop. | `my-workflow` completes and records every `my-implement` phase plus its holistic test gate before dispatching `implement-review`. The five-pass budget begins only afterward, and `implement-review` refuses unfinished planned work rather than executing it. |

## 2026-08-27 — Durable local review confirmations

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `26dea92` | Added a ledger-backed local confirmation for review-sensitive migration, env/config, infra/ops, and lint-suppression changes. | Local review returns one explicit confirmation as review item 1 before fan-out. An affirmative response records `accepted` trigger-content scope in the workflow ledger; unchanged covered triggers are not raised again, while new or modified trigger content requires a fresh confirmation and real defects remain reviewable. |

## 2026-08-27 — Parallel team delivery planning

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `4de164e` | Sized team-plan issues to 3–5 TDD commits and made demos, milestone parallelism, issue caps, and blocker persistence explicit. | Every issue has 3–5 meaningful RED → GREEN → VALIDATE → commit slices; every milestone is team-demoable, targets at most 10 issues with a hard cap of 15, and participates in an acyclic parallel delivery graph. Approved Linear writes preserve and round-trip every direct blocker relationship. |

## 2026-08-27 — Aggregate review risk and human handoffs

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `7266259` | Added aggregate change-set risk classification and one PR human-review handoff for infrastructure and added tooling suppressions. | Genuinely Low-risk sets receive a terse APPROVE before fan-out. Migrations, env/config references, infra/ops changes, and added linter/tooling ignores disqualify that fast path and produce exactly one deduplicated inline human-review annotation for the PR. |

## 2026-08-26 — Actionable review verdicts

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `063a1f9` | Required actionable review feedback and mode-constrained verdicts. | Every surfaced finding or question requests a concrete author-controlled change, decision, or information tied to a changed-line risk. Local, self-authored PR, and unknown-ownership PR reviews return only APPROVE or REQUEST_CHANGES; COMMENT is reserved for third-party PR reviews. |

## 2026-08-25 — Review delivery convergence

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `91e705e` | Allowed `my-review` to approve Low-risk feedback. | With requirements satisfied and no Critical High-risk finding, a review may APPROVE even when substantive Low-risk findings remain; COMMENT is for Medium/High-risk non-blocking feedback or unresolved context. |
| `7f0fc90` | Calibrated `my-review` change-request threshold. | `REQUEST_CHANGES` now requires a per-finding-verified combination of Critical severity and High risk; all other actionable feedback produces `COMMENT`, while `APPROVE` remains limited to minor or clearly optional comments. |
| `053c983` | Added `implement-review` and routed `my-workflow`'s atomic delivery block through it. | One runner owns implementation, validation, whole-branch review, repair, and the five-pass cap; `clean` requires a clean terminal review, while `blocked` and `cap_reached` remain incomplete. `my-review` now emits a deterministic coverage manifest, performs a bounded whole-diff synthesis pass, and enforces requirements, causal-evidence, and final duplicate-detection gates. |
| `f8b34a5` | Added review-first routing to `implement-review`. | A direct run without a plan, or a run whose ledger marks workflow delivery complete, starts with a whole-branch review and repairs verified findings within the existing five-pass cap; active approved plans still implement before review. |
| `3f536ce` | Added the Axon Ecto pipe-style query gotcha across delivery skills. | Implementation, quick delivery, review, and PR-feedback repair treat practical `from(...)` query conversions as the project convention, while preserving documented construct-specific exceptions. |
| `99a5a8d` | Moved review and feedback process reminders into explicit execution contracts. | Gotchas retain code/domain traps; review coverage, requirements mapping, publication boundaries, feedback validation, and PR execution sequencing are mandatory workflow contracts. |

## 2026-08-24 — Durable review-finding dispositions

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `188a02c` | Made `my-review` discover workflow ledgers exclusively from Claude Thoughts. | Review dispatch matches `~/.claude/thoughts/shared/workflows/` by branch before issue/slug context, and only reports no ledger after that lookup. |
| `2ac64fe` | Added an append-only Finding Register shared by `my-review` and `address-pr-feedback`. | Reviews assign stable finding keys and suppress unchanged settled concerns; feedback rounds record only evidence-backed `resolved` or concretely followed-up `deferred` outcomes, reopening a key only for specific new evidence. |

## 2026-08-20 — Cross-runtime runners and model routing

| Commit | Change | Regression boundary / known-good meaning |
|---|---|---|
| `54dfbbe` | Added the explicitly delegated `frontier-model` agent, pinned to Opus/high for Claude and GPT-5.6-Sol/high for Codex. | Use it to give one frontier-model agent complete ownership of a caller-supplied task while retaining the caller's authority boundary. |
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
