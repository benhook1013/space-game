# Development workflow

Accepted working arrangements, 12 September 2026. Ben owns the repository;
the assistant can implement bounded rounds of code, artwork, tests and docs.
This is the process source of truth, not a new gameplay specification.

## Start here

Read `AGENTS.md`, this file, [decisions](docs/development/DECISIONS.md),
[environment notes](docs/development/ENVIRONMENT.md), and the latest entry in
[the round log](docs/development/rounds/). Then inspect the actual working tree.
Use [the WSL guide](docs/development/WSL.md) for clone, apply and return steps.
`PLAN.md` owns product direction; `TASKS.md` owns the active work queue.

Do not repeat a broad tool inventory or repository audit on every turn. Read the
records first; perform only cheap checks or checks relevant to changed conditions.
An uploaded SDK, new runtime or changed source is a reason for a targeted recheck.

## Ownership and authority

The accepted remote repository and Ben's accepted source snapshots are
canonical. A local reconstructed Git commit is not an upstream commit. Track
both provenance and full Git tree hashes so matching content can be verified
without pretending that an uploaded ZIP contains Git history.

The assistant may choose implementation details and execute the next agreed
bounded task without asking permission for every edit. It must state the round's
outcome and exclusions, preserve unrelated behaviour, and explain any material
change of direction. A proposal is not an approved requirement: changing the
endless game to an expedition/contract game remains a separate product decision.

Ben explicitly delegates remote publication of completed rounds to the
assistant (updated 12 September 2026). Prefer a normal, non-forced update to
`main`. When branch protection requires a pull request, the assistant should
create and merge it using the connected tools, subject to required checks,
rather than ask Ben to perform routine integration. Do not disable protections,
force-push or overwrite concurrent edits. Read the current remote head, use
expected-head checks when supported, and verify the resulting remote commit.

Publish only during the active task; this is not a background automation.
If access, required reviews or checks block publication, report the exact
blocker and provide the smallest fallback step or a verified patch. Do not
claim a push or merge succeeded before verifying it. Ben retains product
ownership, can override changes, and supplies device-playtest feedback.
Manual integration instructions elsewhere are fallback procedures, not a
requirement to hand every completed round back to Ben. Do not overlap authors
in the same files.

## Round lifecycle

1. Start from the latest **accepted** snapshot. Record upstream provenance when
   supplied and local base commit/tree. Inspect status; never discard local edits.
2. Name one outcome and its exclusions. Read relevant code and tests before
   editing. Keep dependency/toolchain upgrades separate from gameplay work.
3. Implement complete changes, including tests, asset registrations and relevant
   documentation. Prefer actual files over instructions to manually rewrite code.
4. Run available checks and review the complete diff, including new files,
   deletions, binaries and modes. Explain failed and unavailable validation.
5. Build an incremental binary patch and a complete source-only recovery ZIP.
   Apply the patch to an independent clean copy of the base, then verify the
   resulting Git tree matches the intended source. Check reverse application too.
6. Publish the completed round to `main` through available tools and the
   repository's rules; verify its commit and tree. Deliver recovery files and
   validation results. Use patch handoff only when publication is blocked.
   Start dependent work from the verified published result, including any
   external fixes; Ben provides WSL/CI results and real-device playtest feedback.

Round IDs are `001-process`, `002-pwa-safety`, etc. A replacement is explicitly
labelled, for example `002-pwa-safety-r2`, with the same declared base. Do not
present a replacement as a fixup to an already applied patch. Cumulative patches
must say so; otherwise each round depends on its recorded accepted baseline.

## Delivery contract

```text
space-game-round-001-process/
  changes.patch          # Git binary patch; normal integration route
  source-after.zip       # Complete source; inspection/recovery, NOT an overlay
  BASE.json              # Upstream provenance, local base, base/result tree IDs
  FILES.json             # Result file paths, modes, Git hashes and SHA-256 hashes
  SHA256SUMS             # Handoff artifact checksums
  apply_edit_round.py    # Same helper as scripts/apply_edit_round.py
  CHANGES.md             # Outcome, decisions, changed files and exclusions
  VALIDATION.md          # Commands and PASS / FAIL / NOT RUN status
  PLAYTEST.md            # Actions, expected results, or explicit not-applicable
  HANDOFF.md             # Integration steps and a short coding-agent brief
  previews/              # Optional, only when they help
```

Keep SDKs, dependency caches, build output, Git internals, credentials, browser
profiles and unrelated personal data out of the source ZIP. Do not distribute
system font files. Keep editable artwork and asset credits when applicable.
`FILES.json` records the resulting source tree, not the SDK or handoff itself.

The helper's default is verification only. It checks the patch checksum, clean
worktree/index, exact base tree, applicability and predicted result tree. With
`--apply` it applies/stages the patch and checks the resulting tree. It never
commits, pushes, downloads, resets or changes branches. Read downloaded scripts
before execution. Checksums detect accidental corruption, not publisher identity.

Do not bypass a baseline mismatch with `--reject`, force resets or directory
copying. Return fresh source for a rebased handoff. Equal trees with different
commit histories are acceptable; a changed unrelated tracked file is deliberately
not accepted automatically. Other edits can change behaviour even if hunks apply.

## Validation contract

Report source review, lint/static checks, executed automated tests, Flutter build,
browser execution, offline/update checks and real-device playtesting separately.
Tests written are not tests passed. Browser launch is not a game playtest. A
patch roundtrip only proves file transport. Tests using doubles prove only the
behaviours that the doubles and assertions actually cover.

For a documentation/helper-only round, run helper unit tests, Markdown lint when
available, link checks for new docs, `git diff --check` and patch roundtrip.
Do not claim a Flutter pass or install an SDK merely to edit documentation.

For Dart/game changes, the integration environment should run the pinned SDK:

```bash
# Run from the repository root; see ENVIRONMENT.md before invoking wrappers.
export PUB_CACHE="$PWD/.tooling/pub-cache"
./scripts/flutterw pub get --enforce-lockfile
./scripts/dartw format --output=none --set-exit-if-changed lib test
./scripts/flutterw analyze --no-pub
./scripts/flutterw test --no-pub --concurrency 4
./scripts/flutterw build web --release --no-pub --base-href /space-game/
```

Stop on a failure. Do not remove `--enforce-lockfile` or upgrade dependencies to
make it disappear. Record a pre-existing toolchain/dependency failure and address
it in a scoped compatibility round. Inspect status again after validation.
Use an explicitly supplied SDK's direct binaries only when wrappers would
bootstrap unnecessarily; record that deviation and the SDK version.

Ben has authorized adopting his newer SDK upload in a separate compatibility
round. Do not guess its version or require a download of the old pin. Inspect
platform/version and archive integrity first. Then align FVM, pubspec,
Unix/PowerShell bootstrap versions, checksums, CI assumptions and affected docs;
update dependencies and the lockfile only as needed for compatibility. Report
analysis, tests and release build independently. The upload may still lack pub
packages or web artifacts. Until that round, existing pins remain unchanged.

## Creating a handoff

No custom build framework is required. Commit the intended local result first
(or prepare a temporary commit from reviewed staged changes). Never force-add
ignored tooling. Review untracked files so new assets/tests are not omitted.

```bash
# Example: BASE is an already verified local baseline commit/tag.
BASE=uploaded-baseline
HEAD_COMMIT=$(git rev-parse HEAD)
git diff --check "$BASE" "$HEAD_COMMIT"
git diff --binary --full-index --no-ext-diff --no-textconv \
  "$BASE" "$HEAD_COMMIT" > ../changes.patch
git archive --format=zip --prefix=space-game/ \
  --output=../source-after.zip "$HEAD_COMMIT"
git rev-parse "$BASE^{tree}" "$HEAD_COMMIT^{tree}"
```

Fill `BASE.json` using actual results: `schema_version: 1`, `round_id`,
`upstream_base_commit` (null when unknown), `local_base_commit`, `base_tree`,
`result_tree`, `patch_sha256`, `depends_on`, `patch_kind: "incremental"`,
`source_archive_sha256` and source provenance. Verify against an independent
baseline checkout with the helper; compare all output files and modes with
`FILES.json`. Test the actual packaged patch, not a previous draft. ZIP timestamps
and reconstructed local commit IDs are not proof of upstream identity.

Update the round log with scope, checks, exclusions and next work. Generated logs
belong in the handoff or ignored `.validation/`, not in arbitrary root files.
Never claim the round is merged until Ben or the remote repository confirms it.

## Return loop and resumption

After assistant publication, Ben normally only needs to pull `main` and
playtest. Do not request another upload merely to confirm the assistant's own
verified remote commit. If Ben or Codex changes source outside this workspace,
read the updated remote files or request a fresh committed source ZIP plus the
commit ID, validation output and focused playtest observations. A narrative
summary does not transfer fixes. `git archive HEAD` excludes uncommitted and
untracked changes. Keep build artifacts separate.

Filesystem persistence is not guaranteed. On resumption, inspect the uploaded
archives and restore from the newest accepted one, preserving paths, bytes and
executable bits. Reject absolute/traversal paths and unsafe symlinks during
extraction. A ZIP has no branch history: initialise local Git only as a labelled
reconstruction and record the tree. Do not confuse an older uploaded snapshot
with a newer delivered-but-unaccepted result.

## References

- [Git diff: binary patches and full indexes](https://git-scm.com/docs/git-diff)
- [Git apply: checks and index handling](https://git-scm.com/docs/git-apply)
- [Git archive: committed snapshots](https://git-scm.com/docs/git-archive)
- [Flutter CLI](https://docs.flutter.dev/reference/flutter-cli)
- [Dart pub get and offline cache](https://dart.dev/tools/pub/cmd/pub-get)
