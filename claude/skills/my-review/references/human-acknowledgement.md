# Human Acknowledgements

Some changes need a person to confirm something the repo can't show. They are
not defects. They **never** change the verdict: an otherwise clean PR is still
APPROVE. But every one of them **always** gets an inline comment, whatever the
verdict.

## Triggers

Scan the whole diff. Each trigger is a changed `path:line`.

| Category | What fires it | Ask the author to |
|---|---|---|
| migration | schema or data migrations, backfills | confirm it ran successfully in staging |
| environment-variable | new or changed env var references, declarations, or deploy values | confirm the value is set in every staging and production environment |
| feature-flag | new or changed flag definitions, lookups, defaults, rollout or targeting | confirm the flag is configured in every staging and production environment |
| config | other secrets, config lookups, or deploy-time settings | confirm the operational intent |
| infra-ops | Terraform/Pulumi/CloudFormation, Kubernetes/Helm, deploy manifests, CI/CD workflows, resource limits, networking, permissions, production config | confirm the operational intent |
| lint-suppression | a newly added linter, formatter, type-checker, or static-analysis ignore, inline disable, or config exclusion | confirm the suppression is needed and why |
| modified-existing-test | a changed or deleted test case, assertion, expectation, or skip marker that existed at the base, or shared setup/fixtures those tests use | confirm the changed expectation is intentional and still protects the behavior |

Judge tests per test case. Purely additive tests (new files, new test cases,
helpers only new tests use) never fire.

## Rules

- One inline comment per trigger, anchored on its changed line. A deleted line
  uses `side: LEFT`. Group adjacent lines of the same category into one
  comment with `start_line`.
- Skip a trigger only when an existing thread on that line already asks the
  same thing, including one from an earlier `my-review`. Deduplication is not
  confirmation.
- They bypass the adversarial challenge and the importance filter. The same
  line can also carry a real finding (an unsafe migration, a weakened test);
  that finding goes through the normal path.
- Prior confirmation in the PR doesn't suppress the comment; note it instead.
- Local mode has no PR to comment on: list them as a **Pending before PR or
  staging** checklist with each `path:line`, worded to paste into the PR.

## Comment shape

```markdown
**Acknowledgement needed (not a defect):** <category> — <one line on what changed>.
<the ask from the table, specific to this line>
```
