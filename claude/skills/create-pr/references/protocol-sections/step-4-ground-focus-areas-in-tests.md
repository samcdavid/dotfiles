## Step 4 — Ground Focus Areas in Tests

For each focus area from Step 3, grep the relevant test root for the function or behavior being claimed:

```bash
# Pick the test root that matches the focus area's language/framework
grep -rn "<function_or_behavior>" <test-root>
```

Any focus area whose claimed behavior has **no matching test** becomes a candidate for the **"Where I'm Uncertain"** section. Cap at 3 entries. Be specific — name the file and the claim that no test verifies, not just "this might be wrong." If every focus area has test coverage, omit the section entirely.
