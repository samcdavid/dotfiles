"""Shared parsing for claude/agents/*.md, the single source of truth for
every generated agent format (Codex TOML, OpenCode markdown, and future
targets). Keep this module free of any target-specific rendering."""

from __future__ import annotations

from pathlib import Path
import re


def parse_agent(path: Path) -> tuple[dict[str, str], str]:
    text = path.read_text()
    if not text.startswith("---"):
        raise ValueError(f"{path} does not start with frontmatter")

    match = re.match(r"\A---\s*\n(.*?)\n---\s*\n?(.*)\Z", text, re.DOTALL)
    if not match:
        raise ValueError(f"{path} has malformed frontmatter")

    raw_frontmatter, body = match.groups()
    frontmatter: dict[str, str] = {}
    for line in raw_frontmatter.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            raise ValueError(f"{path} frontmatter line is not key/value: {line!r}")
        key, value = line.split(":", 1)
        frontmatter[key.strip()] = value.strip().strip("\"'")

    for required in ("name", "description"):
        if not frontmatter.get(required):
            raise ValueError(f"{path} is missing required frontmatter key: {required}")

    return frontmatter, body.strip() + "\n"
