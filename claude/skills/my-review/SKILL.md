---
effort: xhigh
name: my-review
description: Rigorous code review modeled on OSS standards. Reviews local changes or GitHub PRs for correctness, cross-service contracts, idempotency, test fidelity, and performance. De-duplicates against existing review comments. Delegates deep investigation and systematic review to the `review-orchestrator` agent; keeps interactive triage, targeted questions, and verdict in the main conversation.
---

# Code Review

Perform a thorough, high-quality code review. Works on local changes (unstaged/staged/committed) or GitHub pull requests.

The heavy lifting (parallel research subagents + systematic checklist application + lens-specific deep-dives) runs inside the `review-orchestrator` agent. This skill stays in the main window only for what genuinely needs you: triage confirmation, targeted questions, adversarial passes, and verdict choice.

## Getting Started

Determine what to review:
- If `$ARGUMENTS` contains a PR number or URL → **PR Mode** (fetch the PR diff via `gh`).
- If `$ARGUMENTS` is empty or `local` → **Local Mode** (review working tree changes via `git diff`).
- If `$ARGUMENTS` contains a branch name → review diff against that branch.

### Read this before producing any output

- `gotchas.md` — known failure patterns for this skill.

## Step 1 — Gather the Diff and Existing Feedback

**PR Mode — read-only via `gh`, never check out the branch.**

The PR diff is the source of truth. The local working tree is NOT — `main` is often behind remote, and other PR branches may not exist locally. Do not try to reach the PR's code through the filesystem.

**HARD CONSTRAINTS (PR Mode):**
- NEVER run `git checkout <branch>`, `git switch <branch>`, `gh pr checkout`, `git fetch origin pull/N/head:<name>`, or any command that changes the working tree, creates a local branch ref, or attempts to "get on" the PR branch.
- NEVER read PR-changed files from the local filesystem (`Read`, `cat`, `grep` on disk paths) and treat the result as the PR's code — that reads `main` (or whatever is checked out), not the PR.
- NEVER compare the PR against local `main` as a substitute for the PR diff. Local `main` is not authoritative; it may lag remote by days.
- The ONLY ways to read PR code are: `gh pr diff <number>` for the diff, and `gh api repos/{owner}/{repo}/contents/{path}?ref={sha}` for full file contents at PR HEAD (sha from `gh api repos/{owner}/{repo}/pulls/{number} --jq '.head.sha'`).

```bash
gh pr diff <number>
gh pr view <number>
gh pr view <number> --json files --jq '.files[].path'

# Full file contents at PR HEAD (when the diff alone isn't enough context):
sha=$(gh api repos/{owner}/{repo}/pulls/<number> --jq '.head.sha')
gh api repos/{owner}/{repo}/contents/<path>?ref=$sha --jq '.content' | base64 -d
```

Also fetch ALL existing review comments and conversation threads:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate
gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate
```

Build an `existing_comments_index` of every issue already raised — file path, line range, substance summary, and `thread_root_id`. You will pass this to the orchestrator for dedupe.

If existing comments include any from **your own prior review pass** on this PR, treat this as a re-review and apply the **"Re-review means full re-review"** gotcha: re-read the full diff, re-read every comment (including issue-level threads where authors often explain what changed), and check whether prior findings are still valid or have been addressed.

**Local Mode:**

```bash
git diff                    # unstaged
git diff --cached           # staged
git log --oneline -5        # recent commits for context
```

The orchestrator will read every changed file fully (not just the diff hunks). You don't need to pre-read.

## Step 2 — Cursory Pass: Identify Review Lenses

Do a quick triage to pick which review **lenses** apply. Lenses drive which checklists the orchestrator applies and which deep-dive subsections appear in the final review.

### Inputs

- PR description, commit messages
- Linear issue, milestone, project, and team context, and the repo's `docs/` for the changed area (fetch them — don't infer; see Requirements checklist below)
- File-level scan of the diff: which areas changed? (backend / frontend / migrations / config / infra / tests / docs / dependency manifests)
- Existing reviewer assignments or labels on the PR

### Lens catalog

| Lens | Scrutinizes | Trigger signals |
|---|---|---|
| **Backend** | Data integrity, query performance, idempotency, error handling, transactions, race conditions, job safety | Server-side code, contexts, schemas, queries, jobs, workers |
| **Frontend** | Accessibility, responsive behavior, state management, render performance, UX consistency, design system adherence | UI components, hooks, stores, CSS, design tokens |
| **Full-stack** | Backend + Frontend with cross-layer wiring scrutiny | Both areas touched in one change |
| **Security** | Auth/authz, input validation, injection vectors, secrets, CORS/CSP, token handling | Auth code, input handlers, queries with user input, file upload, external API creds, security headers |
| **Architecture** | System boundaries, coupling, abstraction quality, scalability, contract design, migration paths | New modules/services, changes to module boundaries, new dependency directions, new infra patterns |
| **Ops** | Deployment safety, observability, failure modes, rollback paths, resource usage, configuration | Health checks, logging, feature flags, config files, deploy manifests, env vars, resource limits |
| **QA** | Test fidelity, coverage gaps, assertion quality, flakiness, test architecture | Test files added/modified, mocks/stubs, new modules without tests |
| **PM** | Requirements coverage, acceptance criteria traceability, scope creep, user-facing behavior | Linked ticket with detailed acceptance criteria, new user-facing behavior |
| **Performance** | Hot-path queries, N+1, caching, indexes, unbounded loops, large-table queries | Queries on large tables, hot endpoints, queue/concurrency changes, caching logic |
| **Migration safety** | Lock risk, down-migration safety, column types, advisory locks, backfillers | Migration files in the diff |
| **Dependency** | License, maintenance, attack surface of new packages | Lockfile changes, new dependency manifests |

If the change has no obvious lens fit, default to **Backend + Security + QA**.

### Requirements checklist

Always look for requirements, not only when a ticket is linked. Build one `requirements_checklist` from both sources below, each entry tagged with where it came from. Pass it to the orchestrator.

**Linear.** Find the issue from the PR description, branch name, commit messages, `$ARGUMENTS`, or a matching thoughts file in `~/.thoughts/work/`. If `$ARGUMENTS` names a milestone, project, or team instead, start there. Fetch each level that exists, using whichever were given or that the issue points to:
- **Issue** — description, acceptance criteria, sub-issues, parent, and comments where PM or design refine scope.
- **Milestone** — its description and target, and sibling issues that define what this change must not break or duplicate.
- **Project** — description, linked project documents and specs, and stated out-of-scope items.
- **Team** — team-level documents or conventions that set requirements. If no issue was found, search the team's open issues for one matching the change before concluding none exists.

**Repo docs.** Read the docs for the changed area: specs, ADRs and contracts under `docs/<area>/`, plus the product and convention rules reached from `docs/guides/` `README.md` and `docs/guides/<app>/README.md`. Documented behavior and conventions count as requirements.

When Linear and the docs disagree, or the change contradicts the docs, raise it as a Targeted Question naming both sources. When the change alters behavior the docs describe and doesn't update them, that's a non-blocking finding. If neither source has anything, say so in triage and ask me once for the source of truth before treating the review as requirements-free.

Activate the **PM** lens whenever the checklist has entries.

### Human acknowledgements

Scan the diff for the triggers in `references/human-acknowledgement.md` and draft one inline comment per trigger. These never change the verdict and are always included in the review, whatever the verdict.

### Tracer triggers

Set `tracer_triggers.neighbor_commits_heuristic = true` if any of the diff's changed files appear in commits whose messages reference a closed Linear issue from `git log --since=60.days --name-only --pretty=format:'%H %s'`. This is the only signal that needs main-context git access — the others (PM lens active, ticket linked, requirements-audit escalated) are already known from triage.

### Plan-file lookup

Find the plan file by searching the contents of `~/.thoughts/work/` for the linked Linear issue ID, not by filename: `rg -il -w '<ISSUE-ID>' ~/.thoughts/work/`. Filenames vary in case and may not carry the ID, and `-w` keeps `MCP-11` from matching `MCP-1152`. Other tickets' files mention an ID as a blocker or sibling, so when several match, pick the one whose title line or `Branch:` line names the ID or the branch under review, and ignore files that only mention it. If none clearly fits, treat it as no plan file rather than guessing.

If found, read the plan's surfaces (Phase sections, "Changes Required" lists, "What We're NOT Doing") and pass them as `plan_surfaces` to the orchestrator.

### Triage output

Produce a short triage block and show it to me before going deep:

```
### Review Triage
- **Intent:** <1–2 sentences in your words — what this change does and why>
- **Lenses identified:**
  - <Lens> — <one-line rationale grounded in the diff>
  - <Lens> — <one-line rationale grounded in the diff>
- **Requirements checklist:** <N> items from <issue / milestone / project / team / docs paths> | none found
- **Human acknowledgements:** <count> · <categories> (or "none")
- **Tracer triggers:** <list which fired, or "none">
```

Proceed automatically unless I override.

## Step 3 — Spawn the orchestrator

Invoke the `review-orchestrator` agent. Pass the full input bundle:

```
- mode: "pr" | "local"
- pr_number, repo, pr_head_sha (PR mode)
- diff_text (the unified diff)
- changed_files
- lenses (active lenses from Step 2)
- existing_comments_index
- requirements_checklist (or null)
- plan_surfaces (or null)
- tracer_triggers
```

The orchestrator spawns research subagents (`codebase-analyzer`, `codebase-pattern-finder`, `docs-researcher`, and conditionally `requirements-tracer`), reads the general checklist plus each active lens-skill's checklist, applies systematic review, and returns structured findings: Blocking Issues, Non-blocking Suggestions, Targeted Questions, What's Good, lens-specific deep-dive subsections, and (if the tracer ran) Related-Issue Regression Risks.

If the orchestrator returns an `## Error` block naming a missing input, surface it and stop — do not try to review with incomplete inputs.

## Step 4 — Targeted Questions

If the orchestrator returned a `### Targeted Questions` block, ask them. The point is to catch things where the situation depends on context only I have.

### After I answer — challenge my answers

Once I respond, spawn the **adversarial-debate** agent to challenge *my* answers. This is a separate pass from the Step 6 finding challenge — the target here is my context, not the assistant's findings.

Pass to the agent:
- The original question + the investigation context that surfaced it (diff, relevant files, orchestrator findings)
- My answer

The agent returns a verdict per answer:
- **ACCEPT** — answer holds up; move on
- **PROBE_FURTHER** — answer has gaps, unverified claims, or optimism bias; the agent supplies a follow-up question to ask me
- **FLAG** — answer reveals a real risk (e.g., "we didn't actually check that", "no, that team wasn't told") that should become a finding

Apply the verdicts:
- ACCEPT → record the answer and proceed
- PROBE_FURTHER → ask me the follow-up question; re-run adversarial debate on the new answer (max 2 cycles, then accept or flag)
- FLAG → record as a structured finding (it will get its own adversarial pass in Step 6 along with every other finding)

### When to skip

If the orchestrator returned no `### Targeted Questions` block, skip this step entirely.

If I've authorized auto-mode (or said "no questions, just review"), log these as a **Questions** section in the final review output (Step 5) instead of pausing. The post-answer adversarial pass is also skipped in this mode — there are no answers to challenge.

## Step 5 — Format the Review

Take the orchestrator's output + user answers + any FLAGged answers from Step 4, and structure the review as follows:

```markdown
## Review: [Brief description of what the change does]

### Verdict
**APPROVE** / **COMMENT** / **REQUEST_CHANGES** — [1 sentence: why this verdict, set by Step 7]

### Summary
[1-2 sentences demonstrating you understood the change and its purpose]

### Blocking Issues

#### 1. [Category]: [Concise issue title]
**File:** `path/to/file.ext:LINE`
**Problem:** [What's wrong and why it matters]
**Fix:**
[Concrete code suggestion — copy-pasteable, not vague guidance]

### Non-blocking Suggestions

#### 1. [Category]: [Concise title]
**File:** `path/to/file.ext:LINE`
**Suggestion:** [What to improve and why]
**Example:**
[Code snippet if helpful]

### Security Deep-Dive
[Only if the orchestrator returned this block — skip otherwise]

### Architecture Assessment
[Only if the orchestrator returned this block — skip otherwise]

### Performance Deep-Dive
[Only if the orchestrator returned this block — skip otherwise]

### Quality Deep-Dive
[Only if the orchestrator returned this block — skip otherwise]

### Requirements Traceability
[Only if the orchestrator returned this block — skip otherwise]

### Related-Issue Regression Risks
[Only if the orchestrator returned this block — skip otherwise]

### Human Acknowledgements
[Every trigger from Step 2, each as its prepared inline comment with `path:line`. In local mode, the "Pending before PR or staging" checklist. Omit only if none fired.]

### Questions
- [Genuine clarifying questions — things where the author has context you don't]

### What's Good
- [Specific positive callouts — not filler, real recognition of good decisions]

### Dropped Findings
- [Findings that failed adversarial self-review — what was considered and why it was dropped]
```

## Step 6 — Adversarial Challenge on Findings

**Always** spawn the **adversarial-debate** agent to challenge every finding before presenting the review. Never skip this step.

Format all blocking issues and non-blocking suggestions (including any FLAGged from Step 4) as structured findings and pass them to the agent along with:
- The PR diff
- The file paths referenced in findings
- The requirements checklist (if built in Step 2)

The agent will return a verdict for each finding: KEEP, DOWNGRADE, REVISE, or DROP — with evidence.

**PR Mode caveat — apply the "Adversarial agent reads the working tree too" gotcha.** The adversarial agent reads the local filesystem (current branch, usually `main`), so for PRs that add new files, those files don't exist locally. When the agent DROPs or REVISEs a finding because something allegedly "doesn't exist," "is fabricated," or "cannot be found," verify the claim against the PR diff before applying the verdict. The diff is the source of truth; if the diff shows the file or identifier is present, override the DROP and KEEP the finding.

Apply the agent's verdicts:
- **KEEP**: present as-is
- **DOWNGRADE**: move from blocking to non-blocking, or from finding to question
- **REVISE**: update the claim or fix based on the agent's feedback
- **DROP**: remove entirely and note in the "Dropped Findings" section

If a finding is revised, retry the adversarial challenge on the revision (max 2 retries). If it still fails, drop it.

### Importance Filter

After applying the adversarial-debate verdicts, run the surviving findings through the importance filter in `references/importance-filter.md` to filter for importance before raising them.

Apply it at `strict` by default (override to `moderate` if QA, PM, or Architecture lenses are active; override to `loose` only if I explicitly ask for a thorough sweep).

Apply the returned verdicts:
- **KEEP** → present as-is in the chosen severity tier
- **DOWNGRADE** → move from blocking to non-blocking, or from finding to question
- **DEFER** → move to a follow-up note rather than a review comment
- **DROP** → remove entirely and add a one-line entry to "Dropped Findings" with the reason

### Post-Challenge Checklist

After applying verdicts, confirm:
- [ ] Blocking vs. non-blocking classification reflects the agent's severity calibration
- [ ] Every surviving finding passed the importance filter
- [ ] No comment duplicates anything already raised in existing review threads
- [ ] Findings are grounded in the diff (or the orchestrator's subagent research), not assumptions
- [ ] Dropped Findings section captures what was filtered out, with reasons

### Docs follow-up

This skill keeps no lessons of its own. When a surviving finding shows a convention or pitfall the repo's `docs/` (read in Step 2) doesn't state, ask one batched question before moving to Step 7:

> "Add any of these to the repo docs? [numbers, 'none', or 'all']"

For each yes, update the guide that covers the area, or add one and link it from that area's README. Follow the rules in `docs/guides/` `README.md` and check every claim against current code. In Local Mode, edit the working tree. In PR Mode, show the proposed text and leave the checkout alone — it isn't the PR's branch.

If I say "none," move on silently. Do not nag, and do not default to "all".

## Step 7 — Adversarial Verdict Challenge

Choose a verdict for the published review and adversarially challenge it. **Always** run this step.

### Propose a verdict

Pick one based on the surviving findings. Human acknowledgements don't count toward the verdict in either direction; an APPROVE still carries them as inline comments.

- **APPROVE** — no blocking issues; non-blocking suggestions are minor or absent; nothing the author needs to fix before merge
- **COMMENT** — non-blocking suggestions or open questions worth raising, but nothing must-fix; also the right choice when context was insufficient to fully verify the change (e.g. PR already merged before review, dependency on another PR)
- **REQUEST_CHANGES** — at least one blocking issue: correctness bug, data risk, security risk, contract break, or missing requirement that should land before merge

### Challenge the proposed verdict

Spawn the **adversarial-debate** agent with:
- The proposed verdict
- The final surviving findings (blocking, non-blocking, questions, deep-dive subsections)
- The triage from Step 2 (lenses, intent)

The agent challenges in **both directions** and returns:
- **KEEP** — proposed verdict stands
- **ESCALATE** — proposed verdict is too soft. Bump up with reason.
- **DE-ESCALATE** — proposed verdict is too harsh. Bump down with reason.

Prompts the agent should consider:
- Is this verdict too soft? Did you miss a blocker hiding in the non-blocking suggestions or deep-dive subsections?
- Is this verdict too harsh? Are the blocking issues actually blocking, or are you over-blocking on preference / style / "I'd write it differently"?
- If APPROVE: does every blocking-class category (correctness, security, contracts, migrations, requirements) have at least one piece of evidence it was actually checked?
- If REQUEST_CHANGES: is the worst finding genuinely "must-fix-before-merge" or just "should-fix-someday"?

### Apply the verdict on the verdict

- **KEEP** → write the verdict at the top of the Step 5 output as proposed
- **ESCALATE** / **DE-ESCALATE** → adopt the agent's recommended verdict and write a one-sentence rationale that names what tipped it

## Guidelines

- Every blocking issue MUST include a concrete fix — write the actual replacement code, not a vague description of what to change.
- Every non-blocking suggestion SHOULD include example code when the alternative isn't obvious.
- Explicitly label severity on every comment: **Bug:**, **Suggestion (non-blocking):**, **Question:**, **Nit:**.
- Ask rather than demand for things where the author may have context you lack — phrase as "Should we...?", "Could we...?", "WDYT of...?" rather than directives.
- Focus on SUBSTANCE — don't bikeshed formatting, naming, or style unless genuinely confusing.
- Cross-service boundaries deserve extra scrutiny — this is where subtle bugs hide.
- Tests should test what they claim to test — vacuously passing tests are worse than no tests.
- NEVER re-raise an issue that already exists in the PR conversation — add to it or skip it.
- Reserve blocking status for things that would break production, lose data, or create security vulnerabilities — do not over-block on style or preference.

## References

- `references/general-checklist.md` — cross-cutting blocking/non-blocking categories. Read by the orchestrator on every invocation.
- `references/human-acknowledgement.md` — triggers and comment shape for changes a person must confirm. Read in Step 2.
- `references/cross-service-contracts.md` — checklist for cross-service changes. Read by the orchestrator on every invocation.
- `references/team-review-patterns.md` — team-and-community review patterns distilled from a multi-developer PR mining pass. Created by a separate mining pass; the orchestrator reads it when present.
- `gotchas.md` — known failure patterns. Both this skill and the orchestrator agent read it.

## Gotchas

Read `gotchas.md` before starting work. The orchestrator agent reads it independently before producing findings. Patterns belonging in this skill's main flow (don't auto-publish, re-review means full re-review) are enforced here; patterns belonging in the deep investigation (lazy imports, cross-service contracts, brand capitalization, PR Mode constraints) are enforced inside the orchestrator.

## Never auto-publish

Producing the final review document is the end of this skill's job. **Do not** run `gh pr review` or any GitHub-mutating command on your own. Wait for explicit direction ("post it", "looks good, publish", "ship it"); then publish the prepared review yourself by following `references/publishing.md`. The user may want to edit findings, add context, or hold the review entirely.
