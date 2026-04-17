---
name: my-eval-plan
description: Design evaluation plans for AI/LLM features. Platform-agnostic — works with Braintrust, LangSmith, custom harnesses, or manual review. Produces scorer definitions, dataset strategies, and baseline targets. Use before building evals, not after.
---

# Eval Plan

Design a rigorous evaluation plan for an AI or LLM feature. This is the thinking-before-building step — what to measure, how to measure it, and what "good" looks like.

## Getting Started

If `$ARGUMENTS` describes a feature or links to a ticket/spec, use that as the starting point. Otherwise, ask: **"What AI feature are you evaluating, and what does it do?"**

Before designing evals, understand:
1. **What does the feature do?** (summarize, generate, classify, extract, route, etc.)
2. **Who are the users?** (end users, internal team, other AI systems)
3. **What does failure look like?** (wrong answer, hallucination, toxic output, slow response, wrong format)
4. **What does success look like?** (accurate, fast, well-formatted, safe, on-brand)
5. **What existing data do you have?** (production logs, labeled examples, user feedback, nothing yet)

Ask these interactively. Don't assume — the user's answers shape the entire plan.

## Step 1 — Define Eval Dimensions

Every AI feature should be evaluated across multiple dimensions. Identify which apply:

| Dimension | What it measures | Example |
|-----------|-----------------|---------|
| **Correctness** | Does the output match expected behavior? | Extraction accuracy, classification F1 |
| **Faithfulness** | Is the output grounded in provided context? | No hallucinated facts, citations check out |
| **Relevance** | Does the output address what was asked? | Answer actually answers the question |
| **Completeness** | Does the output cover all required aspects? | All fields populated, no missing sections |
| **Format compliance** | Does the output match the required structure? | Valid JSON, correct schema, right length |
| **Safety** | Is the output free from harmful content? | No PII leakage, no toxic language, no prompt injection passthrough |
| **Consistency** | Does the same input produce similar quality outputs? | Low variance across runs |
| **Latency** | Is the response time acceptable? | P50/P95/P99 within SLA |
| **Cost** | Is the token/API cost sustainable? | Cost per request within budget |
| **User preference** | Do users actually prefer this over alternatives? | A/B preference, thumbs up/down rate |

For each relevant dimension, define:
- **What "good" means** (threshold, not aspiration)
- **What "bad" means** (failure mode to catch)
- **How to measure it** (automated scorer vs human review vs hybrid)

## Step 2 — Design Scorers

For each dimension, specify a scorer:

### Automated Scorers (for CI/offline evals)
```
Scorer: [name]
Type: [exact_match | fuzzy_match | llm_judge | regex | custom_function | embedding_similarity]
Input: [what the scorer receives — output, expected, context]
Logic: [how it scores — describe the algorithm or prompt]
Output: [0-1 float | pass/fail boolean | categorical label]
Threshold: [minimum acceptable score]
```

### LLM-as-Judge Scorers
For subjective dimensions, design the judge prompt:
- **What to evaluate** (be specific — not "is this good?" but "does this summary contain only facts from the source document?")
- **Rubric** (what each score level means — e.g., 0 = hallucinated, 0.5 = partially grounded, 1 = fully grounded)
- **Few-shot examples** (at least 2 positive and 2 negative examples the judge should calibrate against)
- **Known failure modes** (what the judge should watch for)

### Human Review Scorers
For dimensions that resist automation:
- **Review protocol** (what the reviewer checks, in what order)
- **Rating scale** (binary, 1-5, categorical)
- **Inter-rater reliability plan** (how to ensure consistency across reviewers)

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

## Step 4 — Define Baselines and Targets

| Metric | Current Baseline | Target | Regression Threshold |
|--------|-----------------|--------|---------------------|
| [scorer name] | [current score or "unknown"] | [target score] | [score below which to block deployment] |

If no baseline exists, the first eval run establishes it. Note this explicitly.

## Step 5 — Execution Plan

### Offline Evals (Pre-Deploy)
- **When to run**: On every prompt/model change, on schedule, or manually
- **Where to run**: CI pipeline, eval platform, or local
- **Blocking vs advisory**: Which scorers block deployment vs just warn?

### Online Evals (Post-Deploy)
- **What to monitor**: Which dimensions can be tracked in production?
- **How to sample**: What percentage of production traffic to eval?
- **Alerting**: What score degradation triggers an alert?

### Iteration Loop
```
Change prompt/model → Run offline evals → Compare to baseline
  → Regression? → Investigate and fix
  → Improvement? → Update baseline, deploy
  → Deploy → Monitor online evals → Feed failures back into dataset
```

## Output Format

Deliver the plan as a structured document with:
1. **Feature summary** — one paragraph
2. **Eval dimensions** — table of what's being measured
3. **Scorer definitions** — one block per scorer (automated, LLM-judge, or human)
4. **Dataset plan** — sources, sizes, refresh cadence
5. **Baselines and targets** — table
6. **Execution plan** — when/where/how to run
7. **Open questions** — anything unresolved that needs user input

## Constraints

- Design evals BEFORE building them. This skill produces the plan, not the code.
- Be platform-agnostic in the plan. Note where platform-specific features would help (e.g., "Braintrust's tracing would be useful here") but don't couple the plan to any vendor.
- Don't over-engineer. Start with the 2-3 most important dimensions and expand later. A simple eval that runs is better than a comprehensive one that doesn't.
- Every scorer needs a failure example — if you can't describe what failure looks like, the scorer isn't well-defined.
- Flag when human review is genuinely needed vs. when an LLM judge would suffice. Human review is expensive — use it for calibration, not bulk scoring.
