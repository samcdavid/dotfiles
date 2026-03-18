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
