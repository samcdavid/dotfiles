---
name: freeze
description: Block file edits outside a specified directory. Use during debugging or investigation to prevent accidental changes to unrelated code. Pass the allowed directory as argument.
disable-model-invocation: false
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_SKILL_DIR}/hooks/block-outside-dir.sh"
---

# Freeze — Directory-Scoped Edit Lock

Restricts file edits (Edit and Write tools) to a specified directory. Use when investigating or debugging to prevent accidental changes to unrelated code.

## Usage

```
/freeze src/module/
```

## Workflow

When invoked:
1. Resolve `$ARGUMENTS` to an absolute path (use `pwd` to expand relative paths)
2. Write `{"allowed_dir": "/absolute/path/to/dir"}` to the config file at `${CLAUDE_SKILL_DIR}/freeze-config.json`
3. Confirm: "Freeze active — edits restricted to [directory]."

If `$ARGUMENTS` is empty, ask the user which directory to freeze to.

## Disabling

To disable the freeze, delete `${CLAUDE_SKILL_DIR}/freeze-config.json` or start a new session.
