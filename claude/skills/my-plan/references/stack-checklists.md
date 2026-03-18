# Stack-Specific Planning Checklists

Review the relevant sections when planning changes that touch these stacks.

## Elixir/Phoenix
- [ ] Ecto migrations: reversible with explicit `up`/`down`?
- [ ] Oban jobs: idempotent if retried?
- [ ] Absinthe schema changes: which schema module? Client codegen needed?
- [ ] OpenTelemetry spans: new operations need instrumentation?
- [ ] Umbrella app boundaries: does the change respect app dependency direction?

## React/TypeScript
- [ ] GraphQL client cache invalidation after schema changes?
- [ ] Codegen (`graphql-codegen`, etc.) run after schema changes?
- [ ] i18n string extraction for new user-facing text?
- [ ] Analytics event tracking for new user interactions?
- [ ] Error boundary updates for new failure modes?

## Python/FastAPI
- [ ] Alembic migrations: reversible? Checked with `alembic downgrade`?
- [ ] LangChain/LangGraph state management: state schema changes backward-compatible?
- [ ] Async task idempotency (Celery, background workers)?
- [ ] Type checking alignment (mypy/pyright)?

## Ruby/Rails
- [ ] Sidekiq job backward compatibility (old args still work during deploy)?
- [ ] Migration safety: `strong_migrations` patterns followed?
- [ ] Legacy API contract stability: versioned endpoints affected?

## E2E (Playwright)
- [ ] Which user flows need new or updated tests?
- [ ] Test data setup: deterministic fixtures or seeded state?
- [ ] CI parallelism impact: new tests isolated enough?

## Cross-Service
- [ ] API contract changes: GraphQL, REST, WebSocket — all consumers updated?
- [ ] Shared state: Redis keys, DB tables accessed by multiple services?
- [ ] Deployment order: which service must deploy first?
- [ ] Feature flag coordination: does the flag need to exist in multiple services?
