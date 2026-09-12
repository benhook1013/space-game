# Assistant workspace and toolchain notes

Observed 12 September 2026 while preparing `001-process`. Read this before
repeating setup work. These are dated observations, not permanent platform
capabilities. Ben's WSL environment and this assistant container are different.

## Source baseline and recovery

The complete source is supplied by `space-game-main.zip`, not a successful clone.
Its archive comment names upstream commit:

```text
bb907372a5ba400398b7cae5db994d4593398e36
```

Verified input SHA-256:

```text
ff7afe525190199bfe1b55d7f85dcc7e14afb24ac3a1891a74d614a5f3195377
```

Reconstructing all archive files with executable modes yields Git tree:

```text
1f62779a366287bf7f13c7e120b2dd55a580f2c9
```

There are 267 files totalling 676,576 bytes before this round. This is the source
snapshot, not Git history, dependencies or build output. The older roughly 70 MB
GitHub metadata figure was not a source-snapshot measurement.

The uploaded archive and exported notes survived between turns; the extracted
working copy did not. It was restored again for this round. Current conventional
paths are `/mnt/data/space-game` (working copy) and
`/mnt/data/space-game-baseline` (untouched baseline). These paths are not a
persistence guarantee. Local reconstructed commits have different IDs from
upstream; compare the full tree, not fabricated history.

## Capability observations

| Area | Evidence/status | What to do |
| --- | --- | --- |
| Local files and Git | Rechecked this round: read/write, ZIP extraction, Git 2.47.3 and exact source tree reconstruction work. | Edit files and use verified binary patch handoffs. |
| Platform/storage | Rechecked: Linux x86_64, Python 3.13.5; approximately 29.8 GiB free at inspection. | Use Linux x64 tooling; recheck disk before extracting a large SDK. Free space is not a guaranteed quota. |
| JavaScript | Rechecked: Node 22.16.0 installed. Earlier rounds reported isolated service-worker and transport tests. | Execute current regression tests; do not relabel prior evidence as a fresh run. |
| Flutter/Dart | Rechecked: neither on PATH; no project SDK supplied at round start. | Dart analysis, Flutter tests/build and game playtest are NOT RUN here. |
| Direct network | Prior rounds reported DNS failures for GitHub/raw/archive and `storage.googleapis.com`. Not retried for this documentation round. | Prefer supplied archives. Try a bounded recheck only when relevant conditions change. |
| GitHub connector | Prior rounds retrieved text and a base64 PNG. It is not callable by an ordinary local Python loop. | Useful for selective reads; a complete uploaded snapshot is the reliable baseline route. |
| Browser | Chromium and Playwright are installed. Earlier report: Chromium launched but localhost navigation returned `ERR_BLOCKED_BY_ADMINISTRATOR`; an earlier simple check reportedly worked. | Browser access varies; do not promise a game playtest. Recheck after an actual runnable build is available. |
| Image/audio tools | Rechecked availability: Pillow, CairoSVG, ImageMagick, Inkscape, FFmpeg. Tool availability alone is not an asset-quality check. | Produce/edit files and inspect real outputs; use image-generation tools when available for requested illustrations. |
| Archive tools | Rechecked: unzip, tar and xz installed; no unrar/7z/unar/bsdtar on PATH. Python rarfile exists but is not proof of an available extraction backend. | Prefer the original tar.xz or raw split parts. Do not promise multipart RAR extraction. |
| Markdown lint | No markdownlint executable or local installation found in the inspected locations. | Report full Markdown lint NOT RUN if unavailable; local link/format checks are not equivalent. |

## Flutter pins and bootstrap hazards

The snapshot pins Flutter `3.32.8` in `.fvmrc`, `fvm_config.json`, `pubspec.yaml`
and bootstrap scripts. Keep those values unchanged in this round. Dependency
resolution against the supplied lockfile has not been established here; a
matching SDK version is not a claim that all package constraints are compatible.

Use repo wrappers from the repository root in an online, working environment.
`scripts/flutterw` sources the bootstrap before every invocation. The bootstrap
can download/reinstall the SDK if the installed version is missing or does not
match. It also invokes SDK configuration commands. A wrapper `--version` call
is therefore not a harmless offline presence check.

`setup.sh` is container-oriented: it writes hints under `/root` and falls back
from enforced-lockfile resolution to ordinary `pub get`. Do not run it with
`sudo` in Ben's WSL home. Use the explicit wrapper steps in [WSL.md](WSL.md).
These existing scripts are documented, not changed or certified by this round.
Review any lockfile changes rather than silently accepting them.

## Receiving a Linux SDK

Prefer the original **Linux x64 Flutter 3.32.8 stable** archive, not a Windows
Flutter installation. Keep its original name and supply a SHA-256 checksum.
It can be split without recompression in WSL:

```bash
# Run beside the already-downloaded official Linux archive.
sha256sum flutter_linux_3.32.8-stable.tar.xz > flutter-sdk.sha256
split -b 500M -d -a 3 flutter_linux_3.32.8-stable.tar.xz flutter-sdk.part-
```

Send all `flutter-sdk.part-000`, `001`, etc. plus the checksum file. Here, join
parts in numeric order, verify the checksum and inspect the archive before
extracting it into `.tooling/flutter`. Do not concatenate multipart RAR volumes
as though they were raw split parts; RAR needs a compatible extractor and all
volumes. SDK archives stay outside Git and outside source handoffs.

The SDK may still require web engine artifacts and pub packages. When network
access is unavailable, a compatible pre-cached Linux SDK plus a separately
supplied pub cache may be necessary. In an online environment, the relevant
preparation is `flutter precache --web` followed by project dependency resolution
with the existing lockfile. Run the pinned SDK directly or via reviewed wrappers;
record which. Prefer archives preserving symlinks, executability and SDK metadata.
Inspect caches for unrelated private packages/credentials before uploading.

On receipt: verify platform/version and checksum, inspect paths, restore
permissions, then try version -> offline dependency resolution -> analysis ->
tests -> release build. Record each stage independently. `pub get --offline`
only resolves from available cache; do not assume it fills missing dependencies.
Do not auto-upgrade the SDK or delete existing tooling on an inspection failure.

## Resume without another tool audit

Check repository status and the round baseline first. Read these observations
and the latest round log. Probe only the capability needed for the next step.
For example, inspect a supplied SDK binary directly rather than triggering a
network bootstrap through `flutterw`. Update this file when a capability's
status actually changes, with date, command and error/result. Keep full logs in
the handoff; mark inaccessible historical reports as historical evidence.

## References

- [Flutter SDK archive by platform/version](https://docs.flutter.dev/install/archive)
- [Flutter CLI and precache](https://docs.flutter.dev/reference/flutter-cli)
- [Dart pub get: cache, offline and lockfile](https://dart.dev/tools/pub/cmd/pub-get)
