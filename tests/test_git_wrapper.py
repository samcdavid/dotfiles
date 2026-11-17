#!/usr/bin/env python3
"""Regression coverage for local/bin/git, the hook-bypass-refusing wrapper."""

from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WRAPPER = ROOT / "local" / "bin" / "git"

# Echoes argv one per line so tests can assert exactly what reached "git".
STUB = """#!/bin/sh
echo STUB-GIT
for a in "$@"; do printf '[%s]\\n' "$a"; done
exit "${STUB_EXIT:-0}"
"""

BLOCKED = [
    ["commit", "--no-verify", "-m", "x"],
    ["commit", "-m", "x", "--no-verify"],
    ["commit", "-n", "-m", "x"],
    ["commit", "-nm", "x"],
    ["commit", "-anm", "x"],
    ["commit", "-m", "x", "-n"],
    ["commit", "--no-veri", "-m", "x"],
    ["commit", "--no-verif", "-m", "x"],
    ["commit", "--amend", "--no-edit", "--no-verify"],
    ["-C", "/repo", "commit", "--no-verify"],
    ["-c", "user.name=z", "commit", "-n"],
    ["--git-dir=/x/.git", "commit", "--no-verify"],
    ["--git-dir", "/x/.git", "--work-tree", "/x", "commit", "-n"],
    ["--no-pager", "-p", "commit", "--no-verify"],
    ["--exec-path=/lib/git-core", "commit", "-n"],
    ["push", "--no-verify"],
    ["push", "origin", "main", "--no-verify"],
    ["push", "--no-veri", "origin"],
    ["merge", "--no-verify", "topic"],
    ["pull", "--no-verify"],
    ["rebase", "--no-verify", "main"],
    ["am", "--no-verify", "x.patch"],
    ["am", "-n", "x.patch"],
    ["am", "-3n", "x.patch"],
]

ALLOWED = [
    ["status"],
    ["-C", "/repo", "status"],
    ["log", "-n", "5"],
    ["log", "--no-verify"],
    ["push", "-n", "origin"],
    ["push", "--dry-run", "origin"],
    ["merge", "-n", "topic"],
    ["pull", "-n"],
    ["rebase", "-n", "main"],
    ["merge", "--no-verify-signatures", "topic"],
    ["pull", "--no-verify-signatures"],
    ["show-ref", "--no-verify"],
    ["grep", "-e", "--no-verify"],
    ["commit", "--verify", "-m", "x"],
    ["commit", "--no-edit", "--amend"],
    ["commit", "-m", "n"],
    ["commit", "-mn"],
    ["commit", "-m", "--no-verify"],
    ["commit", "-m", "- fix n"],
    ["commit", "-am", "- fix n"],
    ["commit", "--message", "- fix n"],
    ["commit", "-F", "-"],
    ["commit", "-m", "x", "--", "-n"],
    ["-c", "alias.n=status", "status"],
    ["-c", "core.editor=-n", "commit", "-m", "x"],
]


class WrapperTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        base = Path(self.tempdir.name)
        self.stubbin = base / "stubbin"
        self.wrapbin = base / "wrapbin"
        self.stubbin.mkdir()
        self.wrapbin.mkdir()
        stub = self.stubbin / "git"
        stub.write_text(STUB)
        stub.chmod(0o755)
        # A symlink mirrors how rcm installs it, so self-detection by file
        # identity (not by path) is exercised.
        (self.wrapbin / "git").symlink_to(WRAPPER)

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def run_wrapper(self, args, path=None, **env):
        full_env = {
            "PATH": path or f"{self.wrapbin}:{self.stubbin}:/usr/bin:/bin",
            **env,
        }
        return subprocess.run(
            [str(self.wrapbin / "git"), *args],
            capture_output=True,
            text=True,
            env=full_env,
        )


class RefusalTest(WrapperTestCase):
    def test_blocked_invocations_never_reach_git(self) -> None:
        for args in BLOCKED:
            with self.subTest(args=args):
                result = self.run_wrapper(args)
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertIn("refusing", result.stderr)
                self.assertNotIn("STUB-GIT", result.stdout)

    def test_allowed_invocations_pass_through_unchanged(self) -> None:
        for args in ALLOWED:
            with self.subTest(args=args):
                result = self.run_wrapper(args)
                self.assertEqual(result.returncode, 0, result.stderr)
                expected = "STUB-GIT\n" + "".join(f"[{a}]\n" for a in args)
                self.assertEqual(result.stdout, expected)

    def test_message_names_the_refused_flag(self) -> None:
        result = self.run_wrapper(["commit", "-anm", "x"])
        self.assertIn("'-anm'", result.stderr)


class PassThroughTest(WrapperTestCase):
    def test_exit_status_is_preserved(self) -> None:
        result = self.run_wrapper(["status"], STUB_EXIT="3")
        self.assertEqual(result.returncode, 3)

    def test_empty_and_spaced_arguments_survive(self) -> None:
        result = self.run_wrapper(["commit", "-m", "two words", ""])
        self.assertEqual(result.stdout, "STUB-GIT\n[commit]\n[-m]\n[two words]\n[]\n")

    def test_skips_itself_when_it_appears_twice_on_path(self) -> None:
        path = f"{self.wrapbin}:{self.wrapbin}:{self.stubbin}"
        result = self.run_wrapper(["status"], path=path)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("STUB-GIT", result.stdout)

    def test_no_other_git_on_path_fails_clearly(self) -> None:
        result = self.run_wrapper(["status"], path=str(self.wrapbin))
        self.assertEqual(result.returncode, 127)
        self.assertIn("no git found", result.stderr)

    def test_runs_under_dash_and_bash_posix_mode(self) -> None:
        for shell in ("dash", "bash"):
            exe = shutil.which(shell)
            if exe is None:
                continue
            with self.subTest(shell=shell):
                env = {"PATH": f"{self.wrapbin}:{self.stubbin}:/usr/bin:/bin"}
                args = [exe, "--posix"] if shell == "bash" else [exe]
                blocked = subprocess.run(
                    [*args, str(WRAPPER), "commit", "-nm", "x"],
                    capture_output=True, text=True, env=env,
                )
                self.assertEqual(blocked.returncode, 1)
                allowed = subprocess.run(
                    [*args, str(WRAPPER), "log", "-n", "5"],
                    capture_output=True, text=True, env=env,
                )
                self.assertEqual(allowed.returncode, 0, allowed.stderr)


@unittest.skipUnless(shutil.which("git"), "needs a real git")
class RealGitTest(WrapperTestCase):
    """The stub proves argument handling; this proves the real binary chain."""

    def setUp(self) -> None:
        super().setUp()
        self.repo = Path(self.tempdir.name) / "repo"
        self.repo.mkdir()
        self.env = {
            "PATH": f"{self.wrapbin}:{os.environ.get('PATH', '/usr/bin:/bin')}",
            "HOME": self.tempdir.name,
            "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_CONFIG_SYSTEM": os.devnull,
            "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@example.com",
            "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@example.com",
        }
        self.git("init", "-q")
        hook = self.repo / ".git" / "hooks" / "pre-commit"
        hook.write_text("#!/bin/sh\necho HOOK-RAN >&2\nexit 1\n")
        hook.chmod(0o755)
        (self.repo / "f").write_text("a\n")
        self.git("add", "f")

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.repo, capture_output=True, text=True, env=self.env
        )

    def test_wrapper_is_first_git_on_path(self) -> None:
        found = shutil.which("git", path=self.env["PATH"])
        self.assertEqual(Path(found), self.wrapbin / "git")

    def test_plain_commit_still_runs_the_hook(self) -> None:
        result = self.git("commit", "-m", "x")
        self.assertIn("HOOK-RAN", result.stderr)
        self.assertNotEqual(result.returncode, 0)

    def test_no_verify_is_refused_and_the_hook_is_not_bypassed(self) -> None:
        for flag in (["--no-verify"], ["-n"], ["--no-veri"]):
            with self.subTest(flag=flag):
                result = self.git("commit", *flag, "-m", "x")
                self.assertEqual(result.returncode, 1)
                self.assertIn("refusing", result.stderr)
                head = self.git("rev-parse", "--verify", "-q", "HEAD")
                self.assertNotEqual(head.returncode, 0, "a commit slipped through")

    def test_ordinary_git_commands_work(self) -> None:
        self.assertEqual(self.git("status", "--short").stdout.strip(), "A  f")
        self.assertEqual(self.git("log", "-n", "5").returncode, 128)  # no commits yet
        self.assertEqual(self.git("--version").returncode, 0)


if __name__ == "__main__":
    unittest.main()
