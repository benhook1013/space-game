#!/usr/bin/env python3
"""Verify/apply an edit-round handoff. Python 3.9+, Git; no third-party deps."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile


class HandoffError(Exception):
    """A handoff cannot safely be applied in the current repository."""


def git(repo, *args, env=None):
    """Run Git without a shell; return bytes and preserve useful diagnostics."""
    result = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=True,
        env=env,
        check=False,
        timeout=60,
    )
    if result.returncode:
        detail = result.stderr.decode("utf-8", "replace").strip()
        raise HandoffError(f"git {' '.join(args)} failed: {detail}")
    return result.stdout


def object_id(metadata, key):
    value = metadata.get(key)
    if not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", value):
        raise HandoffError(f"BASE.json contains an invalid {key}.")
    return value


def verify_and_apply(repo, bundle, apply=False):
    """Validate the complete input/output trees; apply only on explicit request.

    Verification uses a temporary index, not the user's index. Git can create
    objects, but check mode does not change tracked files, index or references.
    This is integrity/applicability validation, not a trust or safety sandbox.
    """
    repo = Path(repo).resolve()
    bundle = Path(bundle).resolve()
    if "GIT_INDEX_FILE" in os.environ or "GIT_DIR" in os.environ or "GIT_WORK_TREE" in os.environ:
        raise HandoffError("Unset GIT_INDEX_FILE, GIT_DIR and GIT_WORK_TREE before running.")
    top = Path(git(repo, "rev-parse", "--show-toplevel").decode().strip()).resolve()
    if repo != top:
        raise HandoffError(f"--repo must be the repository root: {top}")
    if bundle == repo or repo in bundle.parents:
        raise HandoffError("Keep the unpacked handoff outside the repository.")

    metadata = json.loads((bundle / "BASE.json").read_text(encoding="utf-8"))
    if not isinstance(metadata, dict) or metadata.get("schema_version") != 1:
        raise HandoffError("Unsupported BASE.json schema; expected schema_version 1.")
    base_tree = object_id(metadata, "base_tree")
    result_tree = object_id(metadata, "result_tree")
    patch = bundle / "changes.patch"
    expected_hash = metadata.get("patch_sha256")
    if not isinstance(expected_hash, str) or not re.fullmatch(r"[0-9a-f]{64}", expected_hash):
        raise HandoffError("BASE.json contains an invalid patch_sha256.")
    if hashlib.sha256(patch.read_bytes()).hexdigest() != expected_hash:
        raise HandoffError("Patch SHA-256 mismatch. Re-download the original handoff.")
    if git(repo, "status", "--porcelain=v1", "--untracked-files=all"):
        raise HandoffError("Working tree/index is not clean. Preserve and resolve local work first.")
    actual_tree = git(repo, "rev-parse", "HEAD^{tree}").decode().strip()
    if actual_tree != base_tree:
        raise HandoffError(
            f"Baseline mismatch: expected {base_tree}, found {actual_tree}. "
            "Do not reset or force apply; request a handoff rebased on accepted source."
        )

    git(repo, "apply", "--check", "--index", "--whitespace=error", str(patch))
    with tempfile.TemporaryDirectory(prefix="space-game-index-") as directory:
        env = dict(os.environ, GIT_INDEX_FILE=str(Path(directory) / "index"))
        git(repo, "read-tree", "HEAD", env=env)
        git(repo, "apply", "--cached", "--whitespace=error", str(patch), env=env)
        predicted = git(repo, "write-tree", env=env).decode().strip()
    if predicted != result_tree:
        raise HandoffError("Patch result does not match BASE.json; tracked files were not changed.")

    # Recheck after validation; another editor/Git process must not run concurrently.
    if apply:
        if git(repo, "status", "--porcelain=v1", "--untracked-files=all"):
            raise HandoffError("Repository changed during verification; nothing applied.")
        if git(repo, "rev-parse", "HEAD^{tree}").decode().strip() != base_tree:
            raise HandoffError("HEAD changed during verification; nothing applied.")
        git(repo, "apply", "--index", "--whitespace=error", str(patch))
        actual = git(repo, "write-tree").decode().strip()
        unstaged = git(repo, "diff", "--no-ext-diff", "--no-textconv", "--name-only")
        if actual != result_tree or unstaged:
            raise HandoffError(
                "Post-apply verification failed. Preserve files for inspection; "
                "no automatic reset was attempted."
            )
    return {"round_id": metadata.get("round_id"), "base_tree": base_tree,
            "result_tree": result_tree, "applied": apply}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path.cwd(), help="Git repository root")
    parser.add_argument("--bundle", type=Path, required=True, help="Unpacked handoff directory")
    parser.add_argument("--apply", action="store_true", help="Apply/stage after all checks pass")
    args = parser.parse_args()
    try:
        result = verify_and_apply(args.repo, args.bundle, apply=args.apply)
    except (HandoffError, OSError, ValueError, subprocess.TimeoutExpired) as error:
        print(f"STOP: {error}", file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2))
    print("PASS: applied and staged; not committed or pushed." if args.apply
          else "PASS: verified only; tracked files and real index unchanged.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
