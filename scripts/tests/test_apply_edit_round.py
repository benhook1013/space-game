"""Offline regression tests for the handoff helper; no Flutter or network."""

import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "apply_edit_round.py"
SPEC = importlib.util.spec_from_file_location("apply_edit_round", SCRIPT)
HELPER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(HELPER)


def run(repo, *args):
    return subprocess.check_output(["git", "-C", str(repo), *args], stderr=subprocess.PIPE)


class ApplyRoundTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        self.repo = root / "repo"
        self.repo.mkdir()
        self.bundle = root / "handoff"
        self.bundle.mkdir()
        run(self.repo, "init", "-b", "main")
        run(self.repo, "config", "user.name", "Test")
        run(self.repo, "config", "user.email", "test@example.invalid")
        run(self.repo, "config", "core.autocrlf", "false")
        (self.repo / "text.txt").write_bytes(b"original\n")
        (self.repo / "delete.txt").write_bytes(b"remove me\n")
        (self.repo / "rename.txt").write_bytes(b"move this\n")
        (self.repo / "image.png").write_bytes(b"\x89PNG\r\n\x00\xffbinary original")
        (self.repo / "run.sh").write_bytes(b"#!/bin/sh\nexit 0\n")
        run(self.repo, "add", "--all")
        run(self.repo, "commit", "-m", "baseline")
        self.base = run(self.repo, "rev-parse", "HEAD").decode().strip()
        self.base_tree = run(self.repo, "rev-parse", "HEAD^{tree}").decode().strip()
        (self.repo / "text.txt").write_bytes(b"edited\n")
        (self.repo / "delete.txt").unlink()
        (self.repo / "rename.txt").rename(self.repo / "renamed.txt")
        (self.repo / "added.txt").write_bytes(b"added\n")
        (self.repo / "image.png").write_bytes(b"\x89PNG\r\n\x00\xffbinary replacement")
        (self.repo / "run.sh").chmod(0o755)
        run(self.repo, "add", "--all")
        self.result_tree = run(self.repo, "write-tree").decode().strip()
        patch = run(self.repo, "diff", "--cached", "--binary", "--full-index",
                    "--no-ext-diff", "--no-textconv", self.base)
        (self.bundle / "changes.patch").write_bytes(patch)
        self.metadata = {"schema_version": 1, "round_id": "test-round",
                         "base_tree": self.base_tree, "result_tree": self.result_tree,
                         "patch_sha256": hashlib.sha256(patch).hexdigest()}
        self.write_metadata()
        # Destructive reset is confined to a newly created disposable test fixture.
        run(self.repo, "reset", "--hard", self.base)

    def write_metadata(self):
        (self.bundle / "BASE.json").write_text(json.dumps(self.metadata))

    def verify(self, apply=False):
        return HELPER.verify_and_apply(self.repo, self.bundle, apply=apply)

    def test_check_changes_neither_index_nor_working_files(self):
        head = run(self.repo, "rev-parse", "HEAD")
        self.assertFalse(self.verify()["applied"])
        self.assertEqual(run(self.repo, "status", "--porcelain"), b"")
        self.assertEqual(run(self.repo, "rev-parse", "HEAD"), head)
        self.assertEqual((self.repo / "text.txt").read_bytes(), b"original\n")

    def test_apply_transports_add_delete_rename_binary_and_mode(self):
        head = run(self.repo, "rev-parse", "HEAD")
        self.assertTrue(self.verify(apply=True)["applied"])
        self.assertEqual(run(self.repo, "write-tree").decode().strip(), self.result_tree)
        self.assertEqual(run(self.repo, "diff", "--name-only"), b"")
        self.assertEqual(run(self.repo, "rev-parse", "HEAD"), head)
        self.assertTrue((self.repo / "run.sh").stat().st_mode & 0o111)
        self.assertFalse((self.repo / "delete.txt").exists())
        self.assertTrue((self.repo / "renamed.txt").exists())

    def test_accepts_same_tree_in_different_history(self):
        run(self.repo, "commit", "--allow-empty", "-m", "independent history")
        self.verify(apply=True)
        self.assertEqual(run(self.repo, "write-tree").decode().strip(), self.result_tree)

    def test_rejects_dirty_tracked_file(self):
        (self.repo / "text.txt").write_bytes(b"local work\n")
        with self.assertRaisesRegex(HELPER.HandoffError, "not clean"):
            self.verify(apply=True)
        self.assertEqual((self.repo / "text.txt").read_bytes(), b"local work\n")

    def test_rejects_staged_changes(self):
        (self.repo / "text.txt").write_bytes(b"staged work\n")
        run(self.repo, "add", "text.txt")
        with self.assertRaisesRegex(HELPER.HandoffError, "not clean"):
            self.verify(apply=True)

    def test_rejects_untracked_files(self):
        (self.repo / "local.txt").write_bytes(b"preserve\n")
        with self.assertRaisesRegex(HELPER.HandoffError, "not clean"):
            self.verify(apply=True)
        self.assertTrue((self.repo / "local.txt").exists())

    def test_rejects_unrelated_committed_baseline_change(self):
        (self.repo / "unrelated.txt").write_bytes(b"new feature\n")
        run(self.repo, "add", "--all")
        run(self.repo, "commit", "-m", "other work")
        with self.assertRaisesRegex(HELPER.HandoffError, "Baseline mismatch"):
            self.verify(apply=True)
        self.assertEqual(run(self.repo, "status", "--porcelain"), b"")

    def test_rejects_tampered_patch(self):
        with (self.bundle / "changes.patch").open("ab") as f:
            f.write(b"corruption")
        with self.assertRaisesRegex(HELPER.HandoffError, "SHA-256 mismatch"):
            self.verify(apply=True)
        self.assertEqual(run(self.repo, "status", "--porcelain"), b"")

    def test_rejects_wrong_result_before_applying(self):
        self.metadata["result_tree"] = self.base_tree
        self.write_metadata()
        with self.assertRaisesRegex(HELPER.HandoffError, "result does not match"):
            self.verify(apply=True)
        self.assertEqual(run(self.repo, "status", "--porcelain"), b"")

    def test_rejects_invalid_metadata(self):
        self.metadata["base_tree"] = "HEAD; unsafe"
        self.write_metadata()
        with self.assertRaisesRegex(HELPER.HandoffError, "invalid base_tree"):
            self.verify(apply=True)

    def test_rejects_unknown_schema(self):
        self.metadata["schema_version"] = 2
        self.write_metadata()
        with self.assertRaisesRegex(HELPER.HandoffError, "Unsupported"):
            self.verify()

    def test_rejects_second_application(self):
        self.verify(apply=True)
        with self.assertRaisesRegex(HELPER.HandoffError, "not clean"):
            self.verify(apply=True)

    def test_requires_repo_root_and_external_bundle(self):
        nested = self.repo / "nested"
        nested.mkdir()
        with self.assertRaisesRegex(HELPER.HandoffError, "repository root"):
            HELPER.verify_and_apply(nested, self.bundle)
        with self.assertRaisesRegex(HELPER.HandoffError, "outside"):
            HELPER.verify_and_apply(self.repo, nested)

    def test_command_line_returns_nonzero_on_failure(self):
        self.metadata["patch_sha256"] = "0" * 64
        self.write_metadata()
        result = subprocess.run(
            [os.sys.executable, str(SCRIPT), "--repo", str(self.repo),
             "--bundle", str(self.bundle), "--apply"], capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn(b"STOP:", result.stderr)
        self.assertEqual(run(self.repo, "status", "--porcelain"), b"")


if __name__ == "__main__":
    unittest.main()
