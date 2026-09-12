# WSL clone, apply and return guide

Ben's source root is `/home/ben/src`. This guide uses a review branch targeting
`main`, not a force-push or a replacement of the remote repository. Run commands
in order and stop on errors. No Flutter installation is needed for round
`001-process` itself.

## First clone

On Ubuntu/Debian WSL, install only missing prerequisites:

```bash
sudo apt-get update
sudo apt-get install -y git unzip python3
```

Clone into the Linux filesystem:

```bash
mkdir -p /home/ben/src
cd /home/ben/src
git clone --branch main https://github.com/benhook1013/space-game.git space-game
```

If `space-game` already exists, inspect it instead of cloning over or deleting
it. GitHub authentication is needed for publishing, not for reading this public
repository. Use your own configured credentials; never put tokens in patches,
chat logs, repository URLs or scripts.

## Move the downloaded handoff into WSL

```bash
cd /home/ben/src
explorer.exe .
```

Copy `space-game-round-001-process.zip` from Windows Downloads into that open
folder. This avoids assuming your Windows username or download path. Then:

```bash
cd /home/ben/src
unzip space-game-round-001-process.zip
cd space-game
git status --short
```

The handoff directory must be beside the repository, not inside it. Do not
extract `source-after.zip` over the clone. Keep the handoff folder unchanged for
its checksums; inspect `HANDOFF.md`, `BASE.json` and `changes.patch` first.

## Verify, then apply

The source tree must exactly match the uploaded baseline. If current `main`
has changed, the helper stops. Send a fresh source snapshot for a rebased round;
do not reset to old code or force a partially applying patch.

```bash
# From /home/ben/src/space-game. Default mode verifies without applying.
python3 ../space-game-round-001-process/apply_edit_round.py \
  --bundle ../space-game-round-001-process --repo .
```

After successful verification:

```bash
git switch -c ai/round-001-process
python3 ../space-game-round-001-process/apply_edit_round.py \
  --bundle ../space-game-round-001-process --repo . --apply
```

The helper stages changes but never commits or pushes. It refuses a dirty tree,
different baseline, corrupted patch, or inconsistent result-tree metadata. It
supports equivalent source trees with different local/upstream commit histories.
Do not run a second time with `--apply` after success; it is intentionally not
idempotent over an already applied round.

Validate and review this process-only round:

```bash
git diff --cached --check && \
python3 -m unittest discover -s scripts/tests -p 'test_*.py' -v && \
git diff --cached --stat

git diff --cached
```

Run Markdown lint on changed Markdown files when available. The full Flutter
suite is not a prerequisite to reviewing this docs/helper-only change; CI may
still run existing checks. Do not report game validation as passed.

## Commit and merge to main

Use your existing Git identity. If Git reports a missing name/email, configure
your own identity locally before retrying the commit; do not copy a fake example
email into a public commit.

```bash
git commit -m "docs: establish verified edit-round workflow"
git push -u origin ai/round-001-process
```

Open a pull request from `ai/round-001-process` into `main`, review the patch and
required checks, then merge through GitHub. This works with protected-branch
workflows without weakening branch protection. If a pre-existing Flutter/CI
failure blocks merging, report it and resolve it explicitly rather than hiding
it in this round. Do not bypass a required check.

After the pull request is merged:

```bash
git switch main
git pull --ff-only origin main
git rev-parse HEAD
git archive --format=zip --output=../space-game-current.zip HEAD
```

Return `space-game-current.zip`, the accepted commit ID and validation output.
The archive contains committed files only: commit intended integration fixes
and new assets before making it. Do not send `.git`, SDKs or caches as part of
this source snapshot. This completes the handoff; the assistant does not
automatically see fixes made in WSL or in another coding agent's workspace.

## Later Dart/game validation

Install missing online-bootstrap dependencies when required, not for this
process patch: `curl`, `xz-utils` and `unzip` on Ubuntu/Debian. Run as Ben, from
the project root. Do not use `sudo ./setup.sh`.

```bash
export PUB_CACHE="$PWD/.tooling/pub-cache"
./scripts/flutterw pub get --enforce-lockfile
./scripts/dartw format --output=none --set-exit-if-changed lib test
./scripts/flutterw analyze --no-pub
./scripts/flutterw test --no-pub --concurrency 4
./scripts/flutterw build web --release --no-pub --base-href /space-game/
```

Stop at the first failure and return the complete error output. These are
commands to execute, not evidence that the baseline currently builds. For a
release preview, serve `build/web` under `/space-game/` to match the base href;
serving it at `/` without matching paths is a different configuration. Device
playtests should state viewport, browser, input type and actions taken.

See [ENVIRONMENT.md](ENVIRONMENT.md) before preparing an offline Linux SDK/cache
upload, and [WORKFLOW.md](../../WORKFLOW.md) for the complete delivery contract.

## References

- [Microsoft WSL filesystems and explorer.exe](https://learn.microsoft.com/en-us/windows/wsl/filesystems)
- [Git clone](https://git-scm.com/docs/git-clone)
- [Git apply](https://git-scm.com/docs/git-apply)
- [Git archive](https://git-scm.com/docs/git-archive)
