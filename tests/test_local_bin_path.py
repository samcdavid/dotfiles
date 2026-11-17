#!/usr/bin/env python3
"""Regression coverage for setup/incrementals/local-bin-path.sh."""

from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "setup" / "incrementals" / "local-bin-path.sh"
MARKER = "# >>> local-bin-path >>>"

# Printed the same way in all three shells: fish joins a quoted path
# variable with colons.
PRINT_PATH = 'printf "%s\\n" "$PATH"'

# Every way a shell reads startup files, minus bash's plain `-c`, which reads
# none and can only inherit PATH.
MODES = {
    "bash": [["-lc"], ["-ic"], ["-lic"]],
    "zsh": [["-c"], ["-lc"], ["-ic"], ["-lic"]],
    "fish": [["-c"], ["-lc"]],
}


def installed(shell: str) -> bool:
    return shutil.which(shell) is not None


class SandboxTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.home = Path(self.tempdir.name) / "home"
        self.home.mkdir()
        self.bin = f"{self.home}/.local/bin"
        # The caller's own PATH, minus its real ~/.local/bin, so the sandbox
        # directory can only come first if the script put it there.
        real = str(Path.home() / ".local" / "bin")
        self.base_path = ":".join(
            p for p in os.environ.get("PATH", "/usr/bin:/bin").split(":") if p != real
        )

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def env(self, **extra):
        return {
            "HOME": str(self.home),
            "PATH": self.base_path,
            "XDG_CONFIG_HOME": str(self.home / ".config"),
            "TERM": "dumb",
            **extra,
        }

    def configure(self, *shells, **extra_env):
        return subprocess.run(
            [str(SCRIPT), *shells],
            capture_output=True,
            text=True,
            env=self.env(**extra_env),
            stdin=subprocess.DEVNULL,
        )

    def path_from(self, shell, flags, command=PRINT_PATH, **extra_env):
        result = subprocess.run(
            [shutil.which(shell), *flags, command],
            capture_output=True,
            text=True,
            env=self.env(**extra_env),
            stdin=subprocess.DEVNULL,
            timeout=30,
        )
        return result.stdout.strip().splitlines()[-1].split(":") if result.stdout.strip() else []

    def read(self, name):
        return (self.home / name).read_text()


class EveryStartupModeTest(SandboxTestCase):
    def check_modes(self):
        for shell, mode_list in MODES.items():
            if not installed(shell):
                continue
            for flags in mode_list:
                with self.subTest(shell=shell, flags=flags):
                    entries = self.path_from(shell, flags)
                    self.assertEqual(entries[:1], [self.bin], entries[:4])
                    self.assertEqual(entries.count(self.bin), 1)

    def test_fresh_home(self) -> None:
        result = self.configure()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.check_modes()

    def test_existing_files_that_prepend_to_path_after_the_fact(self) -> None:
        # What brew shellenv and version managers do: put their own dirs in
        # front. The appended block runs after them.
        (self.home / ".profile").write_text('export PATH="/opt/other/bin:$PATH"')
        (self.home / ".bashrc").write_text('export PATH="/opt/other/bin:$PATH"\n')
        (self.home / ".zshrc").write_text('export PATH="/opt/other/bin:$PATH"\n')
        (self.home / ".zprofile").write_text('export PATH="/opt/other/bin:$PATH"\n')
        result = self.configure()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.check_modes()

    def test_fish_picks_up_an_existing_universal_path(self) -> None:
        if not installed("fish"):
            self.skipTest("fish not installed")
        subprocess.run(
            ["fish", "-c", f"set -U fish_user_paths /opt/other/bin {self.bin} /opt/more/bin"],
            env=self.env(), check=True,
        )
        self.configure("fish")
        entries = self.path_from("fish", ["-c"])
        self.assertEqual(entries[:3], [self.bin, "/opt/other/bin", "/opt/more/bin"])
        self.assertEqual(entries.count(self.bin), 1)


class FileHandlingTest(SandboxTestCase):
    def test_second_run_changes_nothing(self) -> None:
        self.configure()
        names = [".bashrc", ".bash_profile", ".zshenv", ".zprofile", ".zshrc"]
        before = {n: self.read(n) for n in names if (self.home / n).exists()}
        fish_vars = self.home / ".config" / "fish" / "fish_variables"
        fish_before = fish_vars.read_text() if fish_vars.exists() else None
        again = self.configure()
        self.assertEqual(again.returncode, 0, again.stderr)
        self.assertIn("already set", again.stdout)
        self.assertNotIn("updated", again.stdout)
        for name, text in before.items():
            self.assertEqual(self.read(name), text, name)
            self.assertEqual(text.count(MARKER), 1, name)
        if fish_before is not None:
            self.assertEqual(fish_vars.read_text(), fish_before)

    def test_existing_profile_is_used_and_bash_profile_is_not_created(self) -> None:
        (self.home / ".profile").write_text("export KEEP=1")  # no trailing newline
        self.configure("bash")
        self.assertFalse((self.home / ".bash_profile").exists())
        profile = self.read(".profile")
        self.assertTrue(profile.startswith("export KEEP=1\n"), profile)
        self.assertEqual(profile.count(MARKER), 1)
        self.assertIn(MARKER, self.read(".bashrc"))

    def test_bash_profile_wins_over_profile_when_both_exist(self) -> None:
        (self.home / ".profile").write_text("# p\n")
        (self.home / ".bash_profile").write_text("# bp\n")
        self.configure("bash")
        self.assertNotIn(MARKER, self.read(".profile"))
        self.assertIn(MARKER, self.read(".bash_profile"))

    def test_symlinked_startup_file_stays_a_symlink(self) -> None:
        target = Path(self.tempdir.name) / "dotfiles-zshrc"
        target.write_text("# managed elsewhere\n")
        (self.home / ".zshrc").symlink_to(target)
        self.configure("zsh")
        self.assertTrue((self.home / ".zshrc").is_symlink())
        self.assertIn(MARKER, target.read_text())

    def test_zdotdir_is_respected(self) -> None:
        zdot = self.home / "zdot"
        zdot.mkdir()
        self.configure("zsh", ZDOTDIR=str(zdot))
        self.assertTrue((zdot / ".zshenv").exists())
        self.assertFalse((self.home / ".zshenv").exists())

    def test_only_the_named_shell_is_touched(self) -> None:
        self.configure("zsh")
        self.assertFalse((self.home / ".bashrc").exists())
        self.assertFalse((self.home / ".config" / "fish").exists())

    def test_unknown_shell_is_rejected(self) -> None:
        result = self.configure("tcsh")
        self.assertEqual(result.returncode, 1)
        self.assertIn("unknown shell", result.stdout)


class BlockBehaviourTest(SandboxTestCase):
    """The block itself, sourced by each POSIX-ish shell."""

    def block(self):
        self.configure("bash")
        text = self.read(".bashrc")
        start = text.index(MARKER)
        return text[start:]

    def source(self, shell, path):
        script = f'{{block}}\n{PRINT_PATH}'
        result = subprocess.run(
            [shutil.which(shell), "-c", script.replace("{block}", self.block())],
            capture_output=True, text=True,
            env=self.env(PATH=path), stdin=subprocess.DEVNULL,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip().split(":")

    def test_moves_a_later_entry_to_the_front_without_duplicating(self) -> None:
        path = f"/usr/bin:{self.bin}:/bin:/opt/with space/bin"
        for shell in ("dash", "bash", "zsh"):
            if not installed(shell):
                continue
            with self.subTest(shell=shell):
                self.assertEqual(
                    self.source(shell, path),
                    [self.bin, "/usr/bin", "/bin", "/opt/with space/bin"],
                )

    def test_adds_a_missing_entry_and_leaves_a_first_entry_alone(self) -> None:
        for shell in ("dash", "bash", "zsh"):
            if not installed(shell):
                continue
            with self.subTest(shell=shell):
                self.assertEqual(self.source(shell, "/usr/bin:/bin"), [self.bin, "/usr/bin", "/bin"])
                self.assertEqual(self.source(shell, f"{self.bin}:/usr/bin"), [self.bin, "/usr/bin"])

    def test_does_not_leak_helper_variables(self) -> None:
        for shell in ("dash", "bash", "zsh"):
            if not installed(shell):
                continue
            with self.subTest(shell=shell):
                script = self.block() + '\nprintf "[%s]" "${__lb_rest-}${__lb_new-}${__lb_dir-}"'
                result = subprocess.run(
                    [shutil.which(shell), "-c", script], capture_output=True, text=True,
                    env=self.env(PATH="/usr/bin:/bin"), stdin=subprocess.DEVNULL,
                )
                self.assertEqual(result.stdout, "[]")


if __name__ == "__main__":
    unittest.main()
