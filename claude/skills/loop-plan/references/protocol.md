# Protocol — loop-plan

`loop-plan` turns a project idea into Linear milestones and issues through a
conversation that settles one level at a time. The project log is the only
durable artifact: the user's review surface and the resume source of truth.

## Governing constraints

1. **Converse, don't package.** Do not run a spec → research → architecture →
   adversarial pipeline before showing the user anything. Do not dispatch
   `skill-my-spec`, `skill-my-research`, `skill-my-architecture-plan`, or
   `skill-team-plan`. Use a focused read-only agent (`codebase-locator`,
   `codebase-analyzer`, `codebase-pattern-finder`) only when one concrete
   uncertainty blocks the current proposal.
2. **One level at a time.** Settle the idea before outlining milestones;
   confirm the outline before breaking any milestone down; finish one
   milestone's breakdown and Linear write before starting the next.
3. **Later levels may revise earlier ones.** If breaking down a milestone shows
   the outline is wrong — a milestone too big, a demo that cannot work, a
   missing prerequisite — propose the outline change, record the decision, and
   continue. Changes to milestones already written to Linear go through the
   same approval as any other Linear write.
4. **MVP increments with user-facing demos.** Every milestone ships something a
   user can see working and ends in a scripted demo. The first milestone is the
   thinnest end-to-end slice of real value. No milestone exists only for
   setup, infrastructure, migrations, or cleanup — that work lives as tasks
   inside the milestone whose demo needs it.
5. **5–6 tasks per milestone, hard cap 6.** Split an oversized milestone into
   two demoable ones. Accept fewer only with a stated reason; never pad.
6. **Tasks are outcomes, not plans.** Each task is one independently
   reviewable PR that one `/my-loop` run can deliver. Do not write commit plans,
   RED/GREEN steps, or implementation designs into tasks. A task too big for one
   loop session — several behavior paths, broad investigation, or a
   cross-cutting refactor — is split; a task too small to stand alone as a PR
   is merged with tightly related work.
7. **No filler tasks.** No tasks for administration, broad research, vague
   layers, speculative cleanup, or toggles alone. Toggle work belongs in the
   task whose behavior it controls, with its rollout and rollback criteria.
8. **Explicit blockers.** Every prerequisite — task or cross-milestone — is a
   directed `blocked_by` edge recorded in the log and the Linear changes. Reject
   cycles. Distinguish a true start blocker from a merge-order preference.
9. **Migrations stay separate.** A schema or data migration is its own task,
   never combined with the behavior it enables, and blocks that behavior until
   deployed. Apply the safety recipes and expand/migrate/contract ordering in
   `~/.claude/skills/team-plan/references/migration-planning.md`, but ignore its
   commit-plan and migration-milestone guidance: here the migration is a task
   inside the milestone whose user-facing demo it enables, and it carries no
   commit plan.
10. **Approval per milestone, exact changes.** Never create, update, comment on,
    relate, or change the status of a Linear record until the user approves the
    exact changes for the current milestone. Approving the outline or a draft is
    not approval to write. A general request to plan is not authorization.
11. **Persist every turn.** Update the log after every decision, proposal
    change, and Linear write so clearing context never loses state.

## Step 0 — Find or create the log

Match an existing log under `~/.thoughts/projects/` by Linear project, slug,
then topic; resume it. Never create a second log for the same project unless
the user explicitly replaces the first. Create new logs at
`~/.thoughts/projects/<project-slug>.md` from `project-log-template.md`.

If the user supplied a Linear project, milestone, or issue, read it (and its
existing milestones, issues, and blocker relations) read-only. Treat existing
records as proposed work to reconcile, not authoritative requirements. Done
work is context, never reopened. Record only the need and source links, never
copied issue prose.

## Step 1 — Idea

Work out with the user: the problem and who has it, the triggering situation,
what the MVP must prove, and explicit non-goals. When a repository is in scope,
read just enough code to say what already exists and what the plan will rest
on; record that in `Current Understanding` with file/line evidence.

Ask one decision at a time with a recommendation. When the idea is stable,
show it in full and ask whether to move to milestones. Set `status: outlining`
only on confirmation.

## Step 2 — Milestone outline

Propose the ordered milestones. For each: name, goal, what it ships, a numbered
demo script with the visible result, and any cross-milestone blocker naming the
exact capability it needs. Do not list tasks yet; you may note a rough sense of
size to show it fits in 5–6 tasks.

Check the outline before presenting it:

- Does milestone one deliver a real end-to-end user outcome, however thin?
- Does every milestone's demo show something a user can see, not just merged
  code?
- Could any milestone be split into two demoable increments, or merged because
  it only makes sense with its neighbor?
- Is every cross-milestone dependency a real capability blocker?

Iterate on the user's feedback. Record `outline_confirmed_at` and
`status: breaking_down` only on explicit confirmation, and set
`current_milestone` to the first milestone.

## Step 3 — Break down one milestone

For `current_milestone`:

1. **Draft tasks.** Read the code the milestone touches. Propose 5–6 tasks,
   each with outcome, acceptance criteria, demo contribution, out of scope,
   rough surfaces, and blockers. Map every demo step to at least one task, and
   every task to at least one demo step; drop or merge a task that maps to none.
2. **Discuss.** Present the task list with the most relevant current-code
   excerpt. Resolve one decision per turn. If the breakdown shows the outline
   is wrong, propose the outline change (constraint 3) before continuing.
3. **Prepare the Linear changes.** List exactly what will be written: the
   project create-or-reuse decision (first milestone only), the milestone
   record, each issue's title and full description, its milestone membership,
   and every `blocked_by` edge — including edges to issues in earlier
   milestones. List any existing record or edge to change or remove separately;
   nothing is removed by omission. Write each issue description so it stands
   alone as the starting input for `/my-loop`.
4. **Screen.** Dispatch `adversarial-screen` in `decision` mode with the
   milestone draft and the earlier milestones' recorded tasks and edges. Ask it
   to challenge task count, filler, tasks too big for one loop, demo steps no
   task delivers, tasks no demo step needs, missing or cyclic blocker edges,
   and migration tasks bundled with behavior. Apply its verdicts; show the user
   anything it changed.
5. **Approve.** Present the exact changes and ask for explicit approval. Set the
   milestone `Status: approved` only on that answer.
6. **Write.** Re-query Linear for the project, milestone, matching issues, and
   current relations to avoid duplicates or stale edges. Apply exactly the
   approved changes: create or reuse the project, create the milestone, create
   the issues, resolve their IDs, then add every approved blocker edge. If
   Linear rejects part of it or current state differs materially, stop and
   report what was written and what remains; do not retry by creating
   duplicates or widen the change.
7. **Verify.** Re-query every affected record. Confirm milestone membership and
   both directions of every blocker edge. Record URLs in the log, set
   `Status: in_linear`, and advance `current_milestone`.

Stop after each step that needs the user. Do not start the next milestone's
breakdown in the same turn as a Linear write.

## Step 4 — Done

When every milestone is `in_linear`, set `status: done` and return the project
summary: the idea in two sentences, each milestone with its demo and issue
links, the cross-milestone blocker chain, the recommended first issue to start
with `/my-loop`, and any decisions left open.

## Resume rules

Read the log first and route from frontmatter:

- `idea` → Step 1;
- `outlining`, or no `outline_confirmed_at` → Step 2;
- `breaking_down` → Step 3 for `current_milestone`, from its recorded status:
  `outlined`/`drafting` → draft or discuss; `approved` → re-query Linear, then
  write whatever is not yet there; `in_linear` → advance;
- `done` → project summary.

Before resuming a milestone whose status is `approved` or `in_linear`, compare
the log with current Linear records and report any difference rather than
trusting either source silently. Never infer state from conversation memory.

## Gotchas

If a `gotchas.md` file exists in this skill's directory, read it before starting
work.
