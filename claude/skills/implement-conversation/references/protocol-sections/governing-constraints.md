## Governing Constraints

1. **No outward actions.** No `git commit`, `git push`, `gh` state-changing calls. The pipeline produces working-tree changes only.
2. **Autonomous after intake.** After Step 0, run straight through. Sub-skills that ask for interactive input should be supplied the established context and not allowed to re-ask.
3. **Research before asking.** Any question answerable from code or conversation context is not a valid stopping point. Apply the same Blocking-Question Protocol as `my-workflow`.
4. **One intake, then carry context forward.** Never re-ask what was established in Step 0.
5. **A hard failure is a real blocker.** If a stage cannot complete (loop detection trips, a sub-skill errors out), STOP and escalate. Do not skip the stage.
