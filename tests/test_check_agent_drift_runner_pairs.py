#!/usr/bin/env python3
"""Regression coverage for the skill/runner pairing contract."""

from __future__ import annotations

import importlib.machinery
import importlib.util
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "scripts" / "check-agent-drift"


def load_checker_module():
    loader = importlib.machinery.SourceFileLoader("check_agent_drift", str(CHECKER))
    spec = importlib.util.spec_from_loader("check_agent_drift", loader)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


CHECKER_MODULE = load_checker_module()


class RunnerPairValidationTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.fixture = Path(self.tempdir.name)
        (self.fixture / "skills").mkdir()
        (self.fixture / "agents").mkdir()

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def write_pair(
        self,
        *,
        runner: str = "skill-example",
        runner_for: str = "example",
        agent_fields: str = "model: sonnet\neffort: high\ncodex-model: gpt-5.6-terra",
    ) -> None:
        skill = self.fixture / "skills" / "example" / "SKILL.md"
        agent = self.fixture / "agents" / f"{runner}.md"
        skill.parent.mkdir(parents=True, exist_ok=True)
        agent.parent.mkdir(parents=True, exist_ok=True)
        skill.write_text(
            textwrap.dedent(
                f"""\
                ---
                name: example
                runner: {runner}
                ---
                """
            )
        )
        agent.write_text(
            "\n".join(
                [
                    "---",
                    f"name: {runner}",
                    f"runner-for: {runner_for}",
                    agent_fields,
                    "---",
                    "",
                ]
            )
        )

    def run_checker(self) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [str(CHECKER), "--runner-pairs-root", str(self.fixture)],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )

    def test_matching_pair_passes(self) -> None:
        self.write_pair()
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_missing_runner_is_reported(self) -> None:
        self.write_pair(runner="missing-runner")
        (self.fixture / "agents" / "missing-runner.md").unlink()
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("declares runner 'missing-runner', but no flat agent source has that name", result.stdout)

    def test_runner_without_runner_for_is_reported(self) -> None:
        self.write_pair()
        agent = self.fixture / "agents" / "skill-example.md"
        agent.write_text("---\nname: skill-example\nmodel: sonnet\n---\n")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("is runner 'skill-example'", result.stdout)
        self.assertIn("missing runner-for metadata", result.stdout)

    def test_mismatched_runner_for_is_reported(self) -> None:
        self.write_pair(runner_for="other-skill")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("runner-for 'other-skill' does not reciprocate skill 'example'", result.stdout)

    def test_missing_codex_model_is_reported(self) -> None:
        self.write_pair(agent_fields="model: sonnet\neffort: high")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing required runner field: codex-model", result.stdout)

    def test_missing_model_is_reported(self) -> None:
        self.write_pair(agent_fields="effort: high\ncodex-model: gpt-5.6-terra")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing required runner field: model", result.stdout)

    def test_missing_effort_is_reported(self) -> None:
        self.write_pair(agent_fields="model: sonnet\ncodex-model: gpt-5.6-terra")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing required runner field: effort", result.stdout)

    def test_malformed_runner_metadata_is_reported(self) -> None:
        self.write_pair(runner="[skill-example]")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("has malformed runner metadata: runner must be a non-empty agent name", result.stdout)

    def test_unpaired_definitions_remain_valid(self) -> None:
        skill = self.fixture / "skills" / "standalone" / "SKILL.md"
        agent = self.fixture / "agents" / "specialist.md"
        skill.parent.mkdir(parents=True, exist_ok=True)
        agent.parent.mkdir(parents=True, exist_ok=True)
        skill.write_text("---\nname: standalone\n---\n")
        agent.write_text("---\nname: specialist\nmodel: sonnet\n---\n")
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout)

    def write_skill_only_coordinator(
        self,
        *,
        name: str = "my-workflow",
        fields: str = "model: sonnet\neffort: high\nskill-only: coordinator",
    ) -> None:
        skill = self.fixture / "skills" / name / "SKILL.md"
        skill.parent.mkdir(parents=True, exist_ok=True)
        skill.write_text(
            "\n".join(
                [
                    "---",
                    f"name: {name}",
                    fields,
                    "---",
                    "",
                ]
            )
        )

    def test_named_skill_only_coordinator_passes(self) -> None:
        self.write_skill_only_coordinator()
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_other_skill_cannot_be_a_skill_only_coordinator(self) -> None:
        self.write_skill_only_coordinator(name="another-workflow")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(
            "skill-only coordinator is reserved for 'my-workflow'", result.stdout
        )

    def test_skill_only_coordinator_requires_model_and_effort(self) -> None:
        self.write_skill_only_coordinator(fields="skill-only: coordinator")
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing required skill-only coordinator field: model", result.stdout)
        self.assertIn("missing required skill-only coordinator field: effort", result.stdout)

    def test_skill_only_coordinator_cannot_declare_runner(self) -> None:
        self.write_skill_only_coordinator(
            fields="model: sonnet\neffort: high\nskill-only: coordinator\nrunner: skill-workflow"
        )
        result = self.run_checker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("skill-only coordinator cannot also declare runner", result.stdout)


class RecursiveAgentResourceValidationTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tempdir.name)
        self.agents = self.root / "claude" / "agents"
        self.agents.mkdir(parents=True)
        self.old_root = CHECKER_MODULE.ROOT
        self.old_home = CHECKER_MODULE.HOME
        CHECKER_MODULE.ROOT = self.root

    def tearDown(self) -> None:
        CHECKER_MODULE.ROOT = self.old_root
        CHECKER_MODULE.HOME = self.old_home
        self.tempdir.cleanup()

    def test_nested_agent_reference_over_budget_is_reported(self) -> None:
        reference = self.agents / "skill-example" / "references" / "protocol.md"
        reference.parent.mkdir(parents=True)
        reference.write_text("word " * 6001)

        errors: list[str] = []
        CHECKER_MODULE.check_budget(errors)

        self.assertIn(
            "claude/agents/skill-example/references/protocol.md has 6001 words; "
            "reference limit is 6000",
            "\n".join(errors),
        )

    def test_missing_nested_agent_reference_citation_is_reported(self) -> None:
        protocol = self.agents / "skill-example" / "references" / "protocol.md"
        protocol.parent.mkdir(parents=True)
        protocol.write_text("Read `references/missing-resource.md`.\n")

        errors: list[str] = []
        CHECKER_MODULE.check_links(errors)

        self.assertIn(
            "claude/agents/skill-example/references/protocol.md cites missing file: "
            "references/missing-resource.md",
            "\n".join(errors),
        )

    def test_agent_relative_and_home_agent_citations_resolve(self) -> None:
        reference = self.agents / "skill-example" / "references" / "protocol.md"
        helper = self.agents / "skill-example" / "references" / "helper.md"
        reference.parent.mkdir(parents=True)
        helper.write_text("helper\n")
        reference.write_text(
            "Read `references/helper.md` and "
            "`~/.claude/agents/skill-example/references/helper.md`.\n"
        )

        errors: list[str] = []
        CHECKER_MODULE.check_links(errors)

        self.assertEqual(errors, [])

    def test_home_agent_link_and_nested_dangling_reference_are_checked(self) -> None:
        home = self.root / "home"
        CHECKER_MODULE.HOME = home
        for path, target in (
            (home / ".codex" / "agents", self.root / "codex" / "agents"),
            (home / ".agents" / "rules", self.root / "agents" / "rules"),
            (home / ".claude" / "rules", self.root / "claude" / "rules"),
            (home / ".claude" / "agents", self.agents),
        ):
            target.mkdir(parents=True, exist_ok=True)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.symlink_to(target, target_is_directory=True)

        dangling = self.agents / "skill-example" / "references" / "missing.md"
        dangling.parent.mkdir(parents=True)
        dangling.symlink_to("does-not-exist.md")

        errors: list[str] = []
        CHECKER_MODULE.check_home_links(errors, skip_home=False)

        self.assertIn(
            f"dangling home symlink: {home / '.claude' / 'agents' / 'skill-example' / 'references' / 'missing.md'}",
            errors,
        )


if __name__ == "__main__":
    unittest.main()
