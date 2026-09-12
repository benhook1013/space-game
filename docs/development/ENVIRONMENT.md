# Assistant workspace and toolchain notes

Updated 12 September 2026, round `002-review-plan`. This file distinguishes
current observations from earlier session reports. Read it before rediscovering
setup. Ben's WSL environment and the assistant runtime are different machines.

## Current status: local execution unavailable

A bounded retry of a basic `bash -lc` command beginning with
`printf 'workspace-ok\\n'` returned `TransportTimeoutError` before useful output.
It did not inspect or extract an archive. Earlier retries also reported Python
transport timeouts. Python was not separately re-probed for this round.

The GitHub connector successfully read `main`, commit metadata, source and docs.
The accepted baseline at this round's start was
`6b93b7d551bd11e995c71a1620b2b587a471cfe8`, tree
`6a7f0e6a134a474222f610bfd69c7f34697b2b15`.

A transport timeout means the command interface did not return a usable result;
it does not diagnose corrupted uploads, bad Dart source, disk exhaustion or lost
files. The cause and recovery time are unknown. Do not promise a runtime reset
or make new local-file claims without a successful probe.

Reading sources, design review and documentation publication can continue via
GitHub. Local extraction, code execution, builds, asset processing and browser
playtesting cannot presently be verified. Complex code validation can use Ben's
healthy WSL/Copilot or available CI environment instead. No routine extra upload
or optional diagnostic download is needed from Ben.

## Supplied inputs and historical SDK progress

The conversation has these named uploads; local existence/integrity was not
re-established in this round:

- `space-game-main.zip`: original source at `bb907372...`, not today's full
  accepted state after documentation publication.
- `flutter_linux_3.47.4-stable.tar.xz.xz.001` through `.004`: all four SDK parts.
- `space-game-offline-support.zip`: dependency/support bundle received after SDK
  preparation. Its contents, restore script and validation claims remain unread
  by the local runtime because of transport failure.
- `Pasted text.txt`: independent game review, readable through attachment text
  and file search even while local execution fails.

Earlier setup reported assembling the SDK parts, extracting the archive and
successfully launching Linux x64 Flutter 3.47.4 and Dart 3.13.3. Reported identity:

```text
Framework: 9584c6713b324636289d067944a46fd6b49df14b
Engine:    06a2e2a110089dff50fe635cffd2a61e1b24fbcd
```

That setup also reported importing 186 SDK-bundled package archives and resolving
Flutter tooling dependencies offline. Game resolution then stopped at missing
`auto_size_text`; Flame/audio/preferences packages were not yet available.
These are historical execution reports, not fresh checks or a passing game build.
Do not ask Ben to upload the SDK again merely because this runtime is unavailable.

The intended support bundle contains an isolated public Pub cache, tested source
and resolved lockfile, provenance/checksums, restoration instructions and logs,
plus only necessary SDK-cache supplements. Those were packaging instructions,
not a statement that the supplied ZIP has been inspected and meets them.

## Targeted recovery sequence

1. Make one cheap relevant workspace probe. If it still times out, stop local
   setup rather than repeatedly retrying decompression or networking.
2. When execution works, inspect existing directories, uploads, disk space and
   SDK binaries without deleting or reinstalling anything. Do not assume old
   working paths survived or that free-space observations are a storage quota.
3. Read current `main` and compare bundle source/lockfile provenance. The support
   source may predate documentation changes; do not replace newer accepted files.
4. List archive entries and inspect manifest, checksums and restore script before
   extraction/execution. Reject traversal, absolute paths and unsafe links;
   preserve executable permissions and safe SDK links.
5. Reuse the supplied SDK. Restore public dependencies into a dedicated cache,
   regenerate package configuration for current paths and verify offline
   lockfile resolution. Exclude credentials/private packages from committed data.
6. Run analysis, tests and release build independently, recording commands,
   source revision, SDK and failures. Browser/device/offline checks are separate.
7. Migrate repository toolchain pins only as the scoped compatibility round;
   publish through the repository rules after the applicable validation.

## Bootstrap and cache hazards

At the reviewed baseline, the repository still pins Flutter 3.32.8 in `.fvmrc`,
`fvm_config.json`, `pubspec.yaml` and bootstrap scripts. Ben authorized upgrading
to his newer supplied SDK; no pin was changed in this documentation round.

`scripts/flutterw` bootstraps before invocation and can reinstall a mismatching
SDK. A wrapper `--version` is not a harmless offline presence check. Inspect the
supplied binary directly until the migration aligns pins. Do not run `flutter
upgrade`, recreate the scaffold or silently delete/relax a lockfile.

Earlier SDK preparation found that setting an explicit `PUB_CACHE` bypassed its
automatic preload import. The bundled Dart's `pub cache preload` was used for
`.pub-preload-cache/*.tar.gz`, followed by dependency resolution in
`packages/flutter_tools`. Verify with the supplied SDK rather than assuming that
procedure applies to every future release. Do not fake SDK cache stamps.

Existing `setup.sh` is container-oriented and writes under `/root`; do not run it
with sudo in Ben's home merely for project setup. SDKs, caches and generated builds
stay outside tracked source. Verify both Unix and PowerShell version/checksum
changes during migration; do not invent archive hashes for other platforms.

## Historical source and capability observations

The original source ZIP was previously reconstructed as 267 files totaling
676,576 bytes, tree `1f62779a366287bf7f13c7e120b2dd55a580f2c9`.
Its recorded SHA-256 was
`ff7afe525190199bfe1b55d7f85dcc7e14afb24ac3a1891a74d614a5f3195377`.
It contained a source snapshot, not Git history. Earlier roughly 70 MB GitHub
metadata was not a measurement of this source tree.

Historical working paths were `/mnt/data/space-game` and
`/mnt/data/space-game-baseline`. An extracted working copy disappeared between
sessions previously while the uploaded ZIP remained. Neither attachment retention
nor filesystem persistence across future sessions is guaranteed. Never label a
reconstructed local commit as upstream history; verify source trees/provenance.

Earlier successful local checks reported Git 2.47.3, Python 3.13.5, Node 22.16.0,
Linux x86_64 and about 29.8 GiB free at that time. Pillow, CairoSVG, ImageMagick,
Inkscape, FFmpeg, tar, xz and unzip were present. No usable RAR backend was verified.
These observations do not override the current command-transport failure.

Earlier direct downloads failed DNS for GitHub/raw/archive,
`storage.googleapis.com` and pub.dev. GitHub connector text/base64 file reads and
Git object/PR publication worked independently of the terminal network. An
ordinary workspace Python script cannot invoke that connector as a download loop.

Chromium/Playwright previously launched, but localhost navigation was also
reported blocked (`ERR_BLOCKED_BY_ADMINISTRATOR`); an earlier simple browser check
reportedly worked. No full game playtest is established. Recheck only after a
runnable build and healthy runtime exist. Full Markdown lint was previously
unavailable; in this round all local checks are NOT RUN due to transport failure.

## Reporting and resumption

Read decisions and the latest round log. Probe only the next required capability,
not the whole suite. Separate current test output, earlier reports, code inspection
and playtest hypotheses. No game-build pass follows from a launched SDK, no
playtest follows from browser launch and no cache integrity follows from upload
receipt. Record exact remote publication or the exact blocker; do not ask for
another archive merely to confirm the assistant's own remote commit.
