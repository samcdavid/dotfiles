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
