#!/usr/bin/env python3
"""Regression coverage for the skill/runner pairing contract."""

from __future__ import annotations

import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "scripts" / "check-agent-drift"


class RunnerPairValidationTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.fixture = Path(self.tempdir.name)

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
        skill.parent.mkdir(parents=True)
        agent.parent.mkdir(parents=True)
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
        skill.parent.mkdir(parents=True)
        agent.parent.mkdir(parents=True)
        skill.write_text("---\nname: standalone\n---\n")
        agent.write_text("---\nname: specialist\nmodel: sonnet\n---\n")
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout)


if __name__ == "__main__":
    unittest.main()
