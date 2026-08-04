# Replies and Publishing

Load this when drafting or publishing reviewer replies.

Reply shape:

- Acknowledge the reviewer concern.
- State what changed or why no code change was made.
- Cite evidence: tests, files, docs, requirements, or command output.
- Keep pushback falsifiable and respectful.

Publishing rules:

- Inline review comments reply in-thread using the original comment ID.
- Review-body or issue comments get a normal PR conversation reply with quoted context.
- Push commits, publish replies, and mark their threads resolved automatically once verification and self-audit pass — the Step 2 triage confirmation is the explicit request (`no-outward-actions.md`) that authorizes this for the whole run. Never force CI.

