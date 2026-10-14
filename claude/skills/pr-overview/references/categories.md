# Category detection hints

Starting heuristics, not a spec. When a hunk is ambiguous, judge from the surrounding code.

- **Product requirement changes**:
  - business-logic thresholds or limits;
  - validation rules (required fields, formats, allowed values);
  - permission and role checks;
  - user-facing copy, but only when the logic around it also changed.
- **Edited existing test cases**: judge each test case on its own. Include a change or deletion inside a test that existed before, or to shared setup those tests use. Leave out purely additive hunks. Show assertion changes more prominently than mechanical refactors.
- **Migrations**:
  - new files under `db/migrate/`, `migrations/`, `alembic/versions/`, `prisma/migrations/`, or `priv/repo/migrations/`;
  - an ORM model field added, removed, or retyped with no matching migration in the diff.
- **Signature changes**: the declaration line itself changed, such as parameters, types, defaults, return type, or arity. Body-only and call-site changes don't count.
- **Public interface changes**:
  - exported symbols and barrel files;
  - HTTP routes, GraphQL fields and resolvers, gRPC methods;
  - OpenAPI, `.proto`, and `.graphql` contract files.
- **Branching-condition changes**: the condition of an `if`, `case`, `switch`, `when`, or guard changed. Call out changes that alter which branch existing inputs take, separately from brand-new branches.
- **Feature flags**: a flag check added, a flag removed (cleanup), or a flag default or rollout changed. Keep cleanup separate from new gating.
- **Comment quality**: in added or changed comments only, flag:
  - a Linear ID outside a `TODO`/`FIXME`;
  - agent bookkeeping IDs (plan phases, run IDs);
  - dead-code narration;
  - what/how narration instead of why.

  Report the trimmed comment text and the rule it breaks.
- **Monkey patching**: swapping a real module, class, or function at runtime instead of injecting it. Examples:
  - Python: `mock.patch` / `monkeypatch`;
  - Ruby: `allow(...).to receive` on real classes, `stub_const`, `any_instance`;
  - JS/TS: `jest.mock` / `vi.mock` / `spyOn` with an implementation;
  - Elixir: `Mimic` / `:meck` / `Application.put_env`;
  - Go: reassigning a package-level function variable.

  These don't count: config-selected Mox, injected fakes, and HTTP interceptors that don't patch our code. Report production patches separately, and name the injection seam that would replace each patch.
- **Linter suppressions**: new inline disables (`noqa`, `type: ignore`, `eslint-disable`, `@ts-ignore`, `rubocop:disable`, `credo:disable`, `nolint`, and similar). Also count new ignore or exclude entries and loosened rules or thresholds. Name the rule, or say "blanket" when none is named. Note whether a justification comment is present.

# Prepared comments

**Acknowledgement (one per diff).** Write this when a migration, env-var gate, feature flag, edited existing test, or suppression fired. Anchor it at the most consequential one, in this order: migration, env var, flag, edited test, suppression. List the other anchors in the body. Keep only the confirm bullets for categories that fired:

```markdown
Human acknowledgement requested: this PR changes surfaces that need deliberate
human acknowledgement. This is not an automatically identified defect.

- `<path:line>` — <migration | environment-variable | feature-flag | lint/tooling suppression | modified existing test>

Please reply to confirm:
- each changed environment variable has its appropriate value set in every staging and production environment;
- each changed feature flag has its appropriate value/configuration set in every staging and production environment;
- each new migration/backfill has been tested successfully in staging; and
- each edited existing test's changed expectation or coverage is intentional and still protects the desired outcome.
```

**Clarification (one per anchor).** Write one only when the intent is genuinely ambiguous and only the author can answer. Examples: an ORM change with no migration, a condition change with no stated reason, a suppression with no justification, or a requirement change with no ticket. Name the exact fact needed.
