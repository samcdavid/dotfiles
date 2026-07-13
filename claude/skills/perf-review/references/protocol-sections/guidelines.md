## Guidelines

- Focus on MEASURABLE impact, not theoretical concerns — "this query scans 2M rows" beats "this could be slow"
- Every finding needs a concrete fix with expected improvement — not just "add an index"
- Severity must reflect actual scale and frequency, not worst-case imagination
- Premature optimization is real — don't recommend adding caching for a query that runs once a day
- Acknowledge what's done WELL — efficient patterns should be reinforced
- Check the ACTUAL schema, indexes, and data volumes — not assumptions
