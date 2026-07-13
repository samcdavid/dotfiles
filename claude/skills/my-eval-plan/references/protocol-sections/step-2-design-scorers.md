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
