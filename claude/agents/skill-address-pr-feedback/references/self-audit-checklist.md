# Self-Audit Checklist — skill-address-pr-feedback

Load at Step 10, before presenting the final result. Run your changes through the full `/my-review` checklist — the point is to catch anything that would be flagged on re-review. Your fixes should not create new findings.

Read the my-review skill (`~/.claude/skills/my-review/SKILL.md`) Step 5 categories and evaluate your changes against every applicable section below.

## Blocking-level checks on your fixes

- [ ] **Correctness**: No new logic errors, edge cases, or incorrect bang/non-bang usage
- [ ] **Blast radius**: No callers broken, no fallback clauses missing from new pattern matches
- [ ] **Layer boundaries**: No API concerns in contexts, no business logic in resolvers
- [ ] **Idempotency & resilience**: No unbounded loops, retries have safeguards, Oban config correct
- [ ] **Transaction design**: Oban jobs in Multi, no unnecessary `Multi.run`, bulk ops where appropriate
- [ ] **Migration safety**: NOT NULL safe, correct column types, down migration present
- [ ] **Security**: No auth token exposure, routes scoped correctly, input validated
- [ ] **Test fidelity**: Tests assert specific values, not vacuously passing
- [ ] **Test placement**: Unit tests for branching, integration tests for wiring only
- [ ] **Lint discipline**: No checks disabled, no formatter violations, no new warnings
- [ ] **Requirements**: Fixes didn't accidentally remove coverage for a requirement from the original PR

## Non-blocking checks on your fixes

- [ ] **Performance**: No N+1 introduced, no app-side filtering where SQL would work, correct index usage
- [ ] **Existing pattern reuse**: No duplicate utilities, using codebase conventions
- [ ] **Naming**: Names match domain concepts, no magic numbers introduced
- [ ] **Log levels**: Appropriate severity for any new logging
- [ ] **Forward-looking**: Fixes don't reinforce patterns known to be changing

## Output Validation

Screen response drafts, cited SHAs, and direct fix claims with
**adversarial-screen** in `citation` mode and a fingerprinted evidence bundle.
Escalate only a contradiction, missing evidence, disputed causal claim, or
consequential response decision to **adversarial-debate** in `citation` or
`decision` mode.

Format your responses and fix summaries as findings and pass them to the agent along with:

- The committed code (post-fix state)
- The commit SHAs you're referencing
- The investigation claims you're making in responses

The agent will verify:

- File:line references are accurate (lines may have shifted from fixes)
- Quoted identifiers exist in the codebase
- Commit SHAs are real
- Code shown in responses matches actual committed code
- Investigation claims still hold (e.g., "X can be nil here" — is that still true?)

Apply the final adversary's verdicts when escalation occurred; otherwise apply
the screen result — fix invalid references, weaken unverifiable claims, and drop
items that can't be salvaged after 2 attempts.

## Requirements Re-check

If a requirements map was built in Step 1:

- [ ] Re-map every acceptance criterion against the post-fix state of the PR. Did any of your fixes accidentally remove coverage for a requirement?
- [ ] If a fix changed the approach for a requirement (e.g. moved logic to a different layer per reviewer feedback), update the requirements map to reflect the new location.
- [ ] Flag any requirement that is now uncovered or partially covered as a result of your changes.

## Meta-check

- [ ] Every response includes evidence of investigation, not just "done"
- [ ] No fixes introduced that weren't requested (scope creep on the fix round)
- [ ] Contradictions between your fixes and your push-backs? (e.g. fixing a pattern in one place but defending it in another)
- [ ] Importance bar from `/this-important` applied consistently — fixes match the items that survived filtering; dropped/deferred items were not silently fixed anyway
