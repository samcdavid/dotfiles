# Autonomy Boundaries

Load this when a stage wants to ask questions.

The workflow answers factual questions itself by reading artifacts, code, Linear, Notion, Drive, logs, or tests. For genuine decisions — product intent, scope tradeoffs, approach choice, or sign-off on spec/plan — it does not pause mid-stage. It researches the options, picks its own best recommendation, and logs it as a provisional decision in the ledger, then keeps running the pipeline.

Every provisional decision, with options, recommendation, and evidence, surfaces together at the Decisions Checkpoint (after stage 8, `my-analyze`) so the user can confirm or override each one — before the pre-implementation coordination check (stage 9) even runs, let alone implementation. Do not convert a judgment call into a plain assumption just because a reasonable default exists — a provisional decision still needs the user's confirmation; a factual assumption does not.

