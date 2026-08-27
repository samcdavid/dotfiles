# PR Author Calibration

Load in PR mode before reviewer fan-out. Ask which skill level to calibrate
against; default to **Lead** if the user skips the question.

| Level | Calibration |
|---|---|
| **Junior** | Thorough and educational. Explain *why*. Encourage grounded good work. |
| **Mid** | Standard. Explain non-obvious issues; trust the author to implement a clear fix. |
| **Senior** | Concise and direct. Focus on subtle bugs and architecture; skip explanations of well-known patterns. |
| **Lead** | Concise and strategic. Focus on maintainability, team-wide impact, and precedent. |
| **Staff+** | Peer review. Focus on systemic impact, cross-team implications, and design tradeoffs; frame these as discussion. |

Calibration affects explanation depth only. It never permits feedback that fails
`review-contract.md`'s Actionability Gate.
