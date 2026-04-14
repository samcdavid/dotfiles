---
name: perf-review
description: Deep performance review of code changes or a codebase area. Profiles query plans, evaluates index coverage, estimates load impact, checks for resource exhaustion, and audits caching strategy. Goes deeper than performance checks in a code review.
disable-model-invocation: true
---

# Performance Review

Perform a dedicated performance audit. This goes deeper than the performance checks in a code review — it's a focused pass analyzing query efficiency, resource consumption, scalability under load, and caching strategy.

## Getting Started

Determine scope:
- If `$ARGUMENTS` contains a PR number → audit that PR's changes
- If `$ARGUMENTS` contains file paths → audit those files and their callers
- If `$ARGUMENTS` names a feature or area → discover and audit all related code
- If empty → ask the user what to audit

## Step 1 — Map the Hot Paths

Spawn parallel agents:
- **codebase-locator**: Find all files related to the audit scope
- **codebase-analyzer**: Trace data flow from entry points through processing, storage, and response. Identify every database query, external API call, cache interaction, and background job in the changed code paths.

Identify:
- All database queries (reads and writes) in the changed paths
- All external service calls (HTTP, gRPC, message queues)
- All cache reads/writes and their invalidation triggers
- All background jobs and their scheduling/uniqueness configuration
- All loops or iterations over potentially unbounded data sets
- Request/response lifecycle — what happens on every request vs. what's deferred

## Step 2 — Query Analysis

For every database query in the changed paths:

### Query Plan Evaluation
- Does the query have appropriate indexes? Check existing indexes against the WHERE, JOIN, ORDER BY, and GROUP BY clauses.
- Are indexes actually usable by the query's operators? (e.g. `@>` uses GIN, `->>` with `=` does not, LIKE with leading wildcard cannot use B-tree)
- Are there sequential scans on large tables that should be index scans?
- Are there unnecessary JOINs or subqueries that could be simplified?

### N+1 Detection
- Trace loops that issue queries inside iterations — preloading, batch loading, or `insert_all` should replace per-item queries
- Check for hidden N+1s: does a function called in a loop make a query that isn't obvious from the loop body?
- For Ecto: verify preloads cover all associations accessed in the template/serializer

### Unbounded Result Sets
- Are queries missing LIMIT clauses where the result set could grow indefinitely?
- Are pagination strategies correct? (keyset vs. offset — offset pagination degrades on large tables)
- Is `Repo.all` used where `Repo.stream` would be appropriate for large data sets?

### Write Path Analysis
- Are bulk operations used where appropriate? (`insert_all` vs. looping `insert`)
- Are writes inside transactions appropriately scoped? (long transactions hold locks)
- Could write-heavy paths cause lock contention on hot tables?
- Are advisory locks or row-level locks used correctly?

## Step 3 — Resource Consumption

### Memory
- Are large data sets loaded into memory entirely, or streamed/chunked?
- Do GenServers or processes accumulate state without bounds?
- Are there file uploads or downloads buffered fully in memory?
- Could ETS tables or caches grow without eviction policies?

### Connections
- Are database connection pools sized appropriately for the new load?
- Are external HTTP connections pooled and reused, or opened per request?
- Could connection pool exhaustion occur under load? (all connections checked out, new requests block)
- Are connections returned promptly? (no holding connections during slow external calls)

### CPU
- Are there expensive computations on the request path that could be deferred?
- Are there regex operations or JSON parsing on large inputs without size limits?
- Could any computation be memoized or cached?

### Disk / I/O
- Are log volumes appropriate? (verbose logging in hot paths can fill disks)
- Are temporary files cleaned up?
- Are file operations blocking the request path?

## Step 4 — Caching Strategy

- Is caching applied where it would have the highest impact? (frequent reads, expensive queries, stable data)
- Is the cache invalidation strategy correct? (stale data is often worse than no cache)
- Are cache keys specific enough to avoid serving wrong data to wrong users?
- Are TTLs appropriate for the data's rate of change?
- Could cache stampedes occur? (many concurrent requests for the same expired key)
- Is there a thundering herd risk on cache invalidation?

## Step 5 — Scalability Assessment

Think beyond current load:

- If this code path is called 10x, 100x, 1000x more frequently, what breaks first?
- Are there linear-time operations that should be constant-time? (e.g. list scans that should be map lookups)
- Does the design allow horizontal scaling? (no single-process bottlenecks, no local file state)
- Are background jobs configured to handle backpressure? (rate limiting, max concurrency, queue depth)
- Could this change cause cascading failures? (one slow dependency causing timeouts that back up queues)

## Step 6 — Adversarial Challenge

Before presenting, spawn the **adversarial-debate** agent to challenge your performance findings. False positives waste engineering effort on premature optimization — this step is critical.

Format all findings as structured claims and pass them to the agent along with:
- The file paths and code references for each finding
- The query traces from Step 2
- The resource consumption analysis from Step 3

The agent will:
- Verify every file:line reference against current code
- Challenge severity — "you flagged this as an N+1, but is this loop ever called with more than 5 items? Check the callers."
- Steel-man the current approach — "you suggest adding a cache, but this endpoint is called 10 times a day — is the complexity worth it?"
- Verify that query analysis reflects actual schema and indexes (not assumed)
- Check whether suggested optimizations would actually improve the bottleneck or just shift it
- Calibrate impact — distinguish "will page oncall under load" from "could be marginally faster"

Apply the agent's verdicts:
- **KEEP**: finding is real and impact-justified
- **DOWNGRADE**: adjust severity to match actual scale/frequency
- **REVISE**: narrow the claim to what's actually demonstrated
- **DROP**: remove premature optimizations or false positives — note in "Considered and Dismissed" section

After applying verdicts, confirm:
- [ ] Every surviving finding includes a concrete fix with expected impact
- [ ] Severity reflects actual load and scale, not theoretical worst-case
- [ ] No premature optimizations recommended (cost of change > cost of problem)

## Step 7 — Report

```markdown
## Performance Review: [Scope]
Date: [ISO timestamp]

### Critical Findings (will cause incidents under load)
#### 1. [Category]: [Title]
**Location:** `file:line`
**Impact:** [What breaks and at what scale]
**Evidence:** [Query plan, resource trace, or load estimate]
**Fix:** [Concrete remediation with code]
**Expected improvement:** [Quantified where possible]

### High Findings (degraded performance, fix before release)
...

### Medium Findings (optimization opportunities)
...

### Low Findings (marginal improvements)
...

### Query Summary
| Query Location | Type | Index Used | Estimated Cost | Issue |
|---------------|------|-----------|----------------|-------|

### Resource Profile
| Resource | Current Usage Pattern | Risk | Mitigation |
|----------|---------------------|------|------------|

### Caching Opportunities
| Data | Access Pattern | Suggested Strategy | Invalidation |
|------|---------------|-------------------|-------------|

### Positive Patterns
- [Things done well — efficient queries, good caching, proper batching]

### Considered and Dismissed
- [Findings that failed adversarial review — what was considered and why it was dropped]

### Recommendations
1. [Prioritized next steps, ordered by impact]
```

## Guidelines

- Focus on MEASURABLE impact, not theoretical concerns — "this query scans 2M rows" beats "this could be slow"
- Every finding needs a concrete fix with expected improvement — not just "add an index"
- Severity must reflect actual scale and frequency, not worst-case imagination
- Premature optimization is real — don't recommend adding caching for a query that runs once a day
- Acknowledge what's done WELL — efficient patterns should be reinforced
- Check the ACTUAL schema, indexes, and data volumes — not assumptions
