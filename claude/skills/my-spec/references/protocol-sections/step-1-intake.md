## Step 1 — Intake

Determine what we're refining:
- If `$ARGUMENTS` contains a Linear issue ID → fetch the issue and all its context (description, comments, linked issues, project)
- If `$ARGUMENTS` contains a description or idea → use that as the starting point
- If `$ARGUMENTS` contains a URL → fetch and extract the relevant context
- If empty → **read the conversation context first** before asking. Per the "Don't ask a blank intake question" gotcha, when `/my-spec` is invoked mid-conversation it's almost always a continuation. Identify the most likely subject (a ticket just researched, a feature just discussed) and open with a concrete proposal — "Based on our work on [X], I'll use that as the starting point — is that right?" — rather than a blank "What do you want to spec out?"
