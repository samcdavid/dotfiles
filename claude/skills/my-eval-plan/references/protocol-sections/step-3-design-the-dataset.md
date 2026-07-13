## Step 3 — Design the Dataset

### Dataset Strategy
| Dataset Type | Purpose | Size Guidance |
|-------------|---------|---------------|
| **Golden set** | High-quality labeled examples for regression testing | 50-200 cases |
| **Edge cases** | Known failure modes and boundary conditions | 20-50 cases |
| **Production sample** | Random sample from real usage | 100-500 cases |
| **Adversarial set** | Intentionally tricky inputs (prompt injection, ambiguous, out-of-scope) | 20-50 cases |

For each dataset:
- **Source**: Where do the inputs come from?
- **Labels**: How are expected outputs determined? (human-labeled, heuristic, production ground truth)
- **Refresh cadence**: How often should the dataset be updated?
- **Stratification**: Does the dataset cover the full distribution of real inputs? (categories, lengths, languages, edge cases)

### Dataset Anti-Patterns to Avoid
- All examples from the same category or complexity level
- Expected outputs that are too specific (penalizing valid alternatives)
- No adversarial cases (eval only tests the happy path)
- Stale dataset that doesn't reflect current production inputs
