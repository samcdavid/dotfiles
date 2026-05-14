# Gotchas — my-spec

Known failure patterns and lessons learned. Read before starting work with this skill.

### Don't ask a blank intake question when conversation context already identifies the subject
- **Category:** failure-mode
- **Context:** When `/my-spec` is invoked with no arguments, but the current conversation has been clearly focused on a specific ticket, feature, or research topic
- **Wrong:** Asking "What do you want to spec out?" — a blank question that ignores all prior context and forces the user to repeat themselves
- **Right:** Read the conversation context, identify the most likely subject (e.g., the ticket that was just researched, the feature being discussed), and open with a concrete proposal: "Based on our research on [X], I'll use that as the starting point — is that right?" Then proceed with the intake interview.
- **Why:** When a skill is invoked without arguments mid-conversation, it's almost always a continuation of what's already in progress. Asking a blank question wastes the user's time and signals that the context wasn't read.
- **Source:** Skill invoked with no arguments immediately after completing deep codebase research on a specific feature, where the subject was unambiguous from context.
