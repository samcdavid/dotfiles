# Cross-Service Contract Review Checklist

Use when reviewing changes that touch service boundaries or shared data structures.

## Serialization Format Alignment
- [ ] JSON field names match across producer and all consumers
- [ ] Nullable vs required fields agree on both sides
- [ ] Enum values are consistent (string casing, allowed values)
- [ ] Date/time formats are consistent (ISO 8601, Unix timestamps)
- [ ] Numeric precision matches (integer vs float, decimal places)

## Shared Database Tables
- [ ] Schema changes are coordinated — all services that access the table are updated
- [ ] Migration runs in correct order relative to application deploys
- [ ] No service reads columns that another service's migration will drop

## GraphQL Schema Changes
- [ ] Client codegen re-run after schema changes
- [ ] Cache invalidation for affected queries
- [ ] Deprecated fields have removal timeline and no active consumers
- [ ] New nullable fields won't break existing client expectations

## WebSocket/Event Contracts
- [ ] Event names match between producer and consumer
- [ ] Payload shapes are consistent
- [ ] Version negotiation handles old/new clients during deploy

## Shared Infrastructure
- [ ] Redis key namespaces don't collide between services
- [ ] S3 path conventions are consistent
- [ ] Queue names and message formats agree between producer/consumer

## Deployment Order
- [ ] Identify which service must deploy first to avoid breakage
- [ ] Backward-compatible changes deploy before breaking changes
- [ ] Feature flags coordinate multi-service rollout if needed

## Failure-Path Tracing

Shape alignment (above) catches contracts that are wrong on paper. It does not catch defects that only appear when a malformed, duplicate, or unexpected-but-valid value actually reaches the other side — those are invisible from the diff alone and require reading the *consumer's* handling code, not just comparing schemas.

- [ ] For every field this change sends across a service boundary, trace what the **consuming** service actually does with a duplicate, out-of-vocabulary, or boundary value (empty list, max-length string, an enum value the consumer's vocab doesn't have) — does it validate and reject cleanly, or does it crash with an opaque error?
- [ ] For a value that round-trips (written by one service, read back by another, or written then re-read through an API), verify the round-trip against the actual consumer's parsing/mapping code, not just that both sides "look compatible" — a `question_type` or similar enum can fail to round-trip even when both sides' schemas look aligned in isolation.
- [ ] For a bulk/relational write (`insert_all`, upsert, bulk update) that's supposed to preserve associated records (`has_many`, join rows), verify the association actually survives the specific bulk operation used — some bulk paths silently drop associated data that a non-bulk `insert`/`update` would have preserved.
- [ ] For a fix framed as "this satisfies the ticket's correctness definition," check it against the ticket's *full* definition, not just the first predicate — a fix that's one predicate short of the definition looks correct against a partial reading and wrong against production data.
