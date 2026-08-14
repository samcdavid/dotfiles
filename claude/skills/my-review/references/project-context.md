# Linear Project Context

Use this only when the review has a primary Linear issue and that issue belongs to a project. It gives review findings enough delivery context to avoid inventing a second follow-up for work the project already explicitly owns.

## Gather a bounded context

1. Fetch the primary issue with relations. If it has no project, set `project_context: none` and stop. Do not search the workspace or infer a project from the repository, team, or issue title.
2. Fetch the project with milestones and resources, plus its latest status update when available.
3. List the project's `started` and `unstarted` issues separately, with `limit: 50` each. Request only identifiers, titles, descriptions, status/type, URLs, and milestone data. Exclude the primary issue and completed/canceled issues.
4. Summarize the project purpose, milestone ordering, and only the sibling issues whose descriptions materially overlap the review's changed surfaces or surviving findings. Preserve each issue's identifier, status, URL, and the relevant description/acceptance-criterion text.

If a query is unavailable or incomplete, say so in `project_context`; missing context never changes a finding.

## Calibrate follow-up suggestions

After per-finding verification and before importance filtering, inspect every surviving **non-Critical** finding that recommends separate future work (for example: cleanup, refactor, additional coverage, documentation, or a deferred edge case).

Omit a duplicate follow-up only when all of these are true:

- an active or upcoming sibling issue in the same project is `started` or `unstarted`;
- its full description or acceptance criteria explicitly cover the same behavior, surface, and gap—not merely a similar title or theme;
- the current issue does not require that work for its own acceptance criteria; and
- the finding is not a likely production break, security/privacy risk, data-integrity risk, or other Critical concern.

For an exact match, add a concise **Upcoming Project Work** note with the issue link, status, and the concern it owns; do not emit a duplicate suggestion or create another follow-up. A partial match leaves the uncovered portion as a finding. Never treat a future issue as proof that code is correct today, and never suppress a current requirement gap, regression risk, or Critical finding.
