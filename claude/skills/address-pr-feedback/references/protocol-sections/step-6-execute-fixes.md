## Step 6 — Execute Fixes

### Behavioral phases — the orchestration loop

For each behavioral phase, in priority order (blocking before non-blocking):

1. **Assemble the slice** — pass only what this phase needs (the fields from Step 5), not the whole triage or repo. Keep the executor's context small.
2. **Dispatch ONE `implementation-executor`.** One at a time — never two in parallel; they share the working tree and fixes may touch overlapping files. Let it finish before doing anything else. (A `SubagentStop` hook independently re-runs format + lint + the changed tests on what the executor touched — so a green report has already cleared that gate.)
3. **Re-verify independently — you are not the implementer.** Do not take the executor's report on faith:
   - Re-run the phase's mechanical `success_criteria` yourself and read the diff.
   - Check requirements conformance against the slice: does the code satisfy `phase_overview` and the reviewer's actual concern, fully? Do the tests genuinely exercise the corrected behavior, or are they vacuous? Was anything dropped or reinterpreted? Apply the **Fix Quality Bar** above.
   - Confirm the diff stayed within `allowed_paths`.
   - All criteria pass, diff in-bounds, requirements met → phase is genuinely done. Otherwise → Loop Detection.
4. **Record and advance** — mark the phase's todo completed and move to the next. Maintain forward momentum: don't re-open finished phases, don't gold-plate, don't let an executor wander beyond its slice.

#### Loop Detection (orchestrator-owned)

The executor stops itself after one repeated failure; **you** track failures across attempts:

- **First failure** (criterion fails / executor returns `ESCALATE`): diagnose from the report + diff. If the cause is a thin brief (missing path, ambiguous criterion), tighten the slice and re-dispatch **once**.
- **Same check fails a second time** (3rd total): **STOP.** Do not re-dispatch. Surface to the user: what the fix is trying to do, what keeps failing (+ error output), what's been tried, your root-cause theory, and a suggested path forward.
- **`escalation: phase-too-big`**: split the fix into smaller ordered phases and dispatch those, or ask the user.

Escalation is efficiency, not failure. Never power through a 3-strike failure.

### Direct edits — quick-implement-agent

For each non-behavioral direct edit, dispatch it as a `direct_edit` phase to `quick-implement-agent`. The SubagentStop hook fires identically to behavioral phases (format + lint + changed tests) — direct edits clear the same gate.

Assemble the slice:
- `phase_name` / `phase_overview` — the reviewer's concern and what the fix does
- `phase_type: "direct_edit"`
- `edit_target` — file path + function name + line range (re-read the file before specifying; state may have shifted from earlier fixes in this session)
- `edit_description` — what the edit does, plus any **Fix Quality Bar** constraints relevant to this fix (encode them so the agent doesn't violate them)
- `success_criteria` — grep/lint/test checks that confirm the edit is correct and regressions are absent
- `allowed_paths` — the file(s) for this fix
- `verification_commands` — lint + relevant test command

Dispatch ONE `quick-implement-agent` per direct-edit phase. Sequential — never parallel.

Re-verify independently: read the diff, confirm the edit addressed the reviewer's underlying concern (not just the surface suggestion), confirm no ripple effects on callers or other files in the diff. Apply the **Fix Quality Bar** in your re-verify pass.

### Plan deviations

If reality differs from the plan (reported by an executor or found on re-verify): **minor** — accept the adaptation, note it, continue; **major** (a file the plan assumed doesn't exist, an API changed, the fix needs files outside every `allowed_paths`) — STOP and discuss.
