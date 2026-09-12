# Working decisions

Recorded 12 September 2026. These decisions capture the conversation that led to
round `001-process`. They are durable agreements, unlike runtime observations in
[ENVIRONMENT.md](ENVIRONMENT.md). Update this record when decisions change.

## Accepted: implement, do not only advise

Ben delegates bounded implementation rounds to the assistant: source editing,
asset creation/integration, tests, reviews and usable patch delivery. The
assistant can select details and advance the agreed queue without repeated
confirmation. Ben retains product ownership, acceptance and remote publication.
This round changes process documentation and the handoff helper only.

## Accepted: local work, patch handoff, WSL acceptance

The source of truth remains `benhook1013/space-game`, with accepted changes
integrated into `main`. Ben's WSL source root is `/home/ben/src`; the clone is
`/home/ben/src/space-game`. Work on a review branch and merge through the
repository's normal rules. Do not assume direct pushes to `main` are allowed.

The assistant delivers a numbered ZIP containing an incremental binary Git
patch, complete result snapshot, provenance, checks and instructions. The result
snapshot is for recovery, not for copying over a repository. Accept only an exact
base tree by default, and return fresh source after integration changes.

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
