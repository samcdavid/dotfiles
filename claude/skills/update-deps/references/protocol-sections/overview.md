---
model: sonnet
name: update-deps
description: Update all outdated dependencies in a project. Auto-detects language and package manager from project files (mix.exs, package.json, pyproject.toml, Cargo.toml, go.mod, Gemfile, etc). Handles safe updates and breaking changes with changelog lookup. Manual invocation only.
disable-model-invocation: true
---

# Update Dependencies

Update all outdated dependencies in the current project. Auto-detects language, package manager, and verification commands.
