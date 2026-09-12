# Working decisions

Recorded and updated 12 September 2026. These decisions capture round
`001-process` and Ben's subsequent delegation of publication and SDK upgrade.
They are durable agreements, unlike runtime observations in
[ENVIRONMENT.md](ENVIRONMENT.md). Update this record when decisions change.

## Accepted: implement, do not only advise

Ben delegates bounded implementation rounds to the assistant: source editing,
asset creation/integration, tests, reviews and usable patch delivery. The
assistant can select details and advance the agreed queue without repeated
confirmation. Ben retains product ownership and may override decisions;
remote publication of completed rounds is also delegated to the assistant.
The process round changes documentation and the handoff helper only.

## Accepted: assistant publishes to main

Ben explicitly requested automatic publication by the assistant instead of
requiring him to apply each round and operate a feature-branch/PR workflow.
The source of truth remains `benhook1013/space-game`, targeting `main`.
Ben's WSL clone is `/home/ben/src/space-game`; after publication he normally
only needs to pull and playtest. This supersedes the initial manual-integration
default in the Round 001 handoff and older WSL/product-document instructions.

Use a normal non-forced update when permitted. If the repository requires a PR,
the assistant should create and merge it through the connector and respect
required checks/reviews. Do not weaken protection or force-push. If publication
is blocked, explain the exact blocker instead of claiming success. Verify the
remote result and retain a recoverable source snapshot/patch. This delegation
applies during active work, not autonomous work between messages.

A verified patch ZIP remains the fallback when remote publication is unavailable.
Preserve provenance and exact base/result trees; recovery snapshots are not for
blindly copying over a clone. Retrieve external changes before dependent work.

## Accepted: adopt the newer supplied SDK in a compatibility round

Ben has already downloaded a later SDK and authorized using it once supplied.
Inspect the archive's actual version, platform and integrity before editing
pins; do not guess a release or ask for the old 3.32.8 archive again. Linux x64
is needed for this workspace. The prior ENVIRONMENT.md preference for a
3.32.8 upload is superseded by this decision, not by an unverified SDK change.

Keep the migration separate from gameplay. Align FVM configuration, pubspec,
Unix/PowerShell bootstrap versions and checksums, CI assumptions and relevant
docs; adjust dependencies and the lockfile only where compatibility requires.
Run analysis, tests and a release build where possible, reporting missing pub
packages/web artifacts separately from SDK installation. Until the archive is
supplied and inspected, the existing SDK pins stay unchanged.

## Accepted: separate design, execution and evidence

Keep Flutter/Flame and the lightweight offline, mobile-first mining/combat
concept. Do not rewrite the engine or add a backend as part of this process work.
Target complete player-facing improvements, not an ever-growing demonstration.

Working priority: make delivery reliable once, then address the identified PWA
cache-safety issues in a bounded round, then focus on the opening experience,
enemy differentiation, readable feedback and useful upgrade choices. Do not
spend multiple rounds expanding process infrastructure without a demonstrated
need. Keep new background systems, multiplayer, accounts and native-store work
deferred while the core game remains unproven.

## Proposed, not adopted as a specification

A short expedition with a mining contract, extraction/final encounter and
run-specific upgrades was suggested. An 8-12 minute session, three enemy roles,
and particular economy targets are candidate tuning ideas, not approved product
requirements. Changing the run format or permanent progression needs a named
product decision, trade-offs and a small playable test, not silent implementation.

An initial small vector-style ship/enemy/pickup set is a suggested art workflow.
It has not established the final visual style. Assess silhouettes at gameplay
size and integrate assets/manifests only as part of a scoped art round.

## Accepted: environment failures are observations, not identities

Use uploaded source when direct GitHub downloads fail. An individual connector
fetch is not an automated filesystem download, and a local Git diff does not
fetch a remote branch. Do not repeatedly retry known failing network/bootstrap
paths without changed conditions. A Linux SDK upload is grounds for a targeted
SDK check; it does not itself prove dependency availability or browser access.

Record PASS, FAIL and NOT RUN separately. Preserve external build and playtest
feedback. A passing transport test or code review is never a substitute for
running the game. The repository must retain enough context to resume without
re-reading the chat or assuming an earlier workspace still exists.
