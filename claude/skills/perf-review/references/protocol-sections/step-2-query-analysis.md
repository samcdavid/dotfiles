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
