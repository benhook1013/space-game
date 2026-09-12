# Working decisions

Updated 12 September 2026 after Ben supplied the independent review.
These are durable working decisions; runtime observations belong in
[ENVIRONMENT.md](ENVIRONMENT.md). [PLAN.md](../../PLAN.md) owns the product
roadmap, [DESIGN.md](../../DESIGN.md) the intended behaviour and
[TASKS.md](../../TASKS.md) the queue. The rationale and evidence are in
[round 002](rounds/002-review-plan.md).

## D1: implement and publish, not only advise

Ben delegates bounded source/asset/test/documentation implementation to the
assistant and authorizes publication to `main`. The assistant chooses details
without repeatedly asking permission; Ben retains product ownership and can
redirect work. Use a normal non-forced update when permitted. When a PR is
required, create and merge it through available tools, respecting checks and
reviews. Never weaken protection, force history or overwrite concurrent work.
Verify the actual published result before claiming success.

The accepted repository is `benhook1013/space-game`. Ben's WSL clone is
`/home/ben/src/space-game`; his usual task is pull and playtest, not applying
patches and operating PRs. Work happens during active tasks, not autonomously
between messages. Round 001 reached `main` at
`6b93b7d551bd11e995c71a1620b2b587a471cfe8`; its initial unmerged handoff language
is historical, not current publication status.

## D2: do not give Ben unnecessary downloads

Routine output is a concise change/validation report and the relevant repository
reference. Retain recovery provenance where possible but do not present optional
diagnostic ZIPs, duplicate prompt files or recovery archives as user action.
Use verified patch handoffs only when necessary or requested. Never ask for
another source upload merely to confirm an assistant-published commit.

## D3: adopt the supplied SDK in a compatibility-only round

Ben authorized his newer Linux SDK rather than another 3.32.8 download. Earlier
setup reported Flutter 3.47.4 / Dart 3.13.3 launching; the support bundle has now
been supplied, but restoration and a game build remain unverified.

Inspect actual version/platform, archive integrity, bundle provenance and any
lockfile changes before using them. Align FVM, pubspec, both bootstrap platforms,
checksums, CI assumptions and affected docs; change dependencies only as required.
Do not run an old-pin wrapper over a newer SDK as a harmless presence check.
Until the validated compatibility round, existing pins stay unchanged. No SDK,
package cache, build output or credentials enter source control.

## D4: harvest-first development; release format decided by a matched test

Adopt the review's sequencing correction: improve harvesting under pressure
before committing to an expedition. Endless play is the initial development
baseline, not a proven preferred final format. Compare that improved game with
one ending immediately at a cumulative ore target, holding controls, resources,
encounters and starting profiles constant. Choose one headline mode.

This explicitly revises the previous expedition proposal. Extraction, a boss,
three enemy roles, an 8-12-minute session, six to eight run upgrades and replacing
permanent power are not accepted release requirements. A useful quota does not
automatically justify the rest of that bundle. If both formats lack enjoyable
decisions, fix the shared loop rather than expanding content.

## D5: collected ore has purpose beyond the shop

Implement cumulative ore collected as the primary score alongside a spendable
wallet. Spending changes the wallet, not earned harvest or quota progress.
These are two measurements of the same resource, not two currencies. Credit
collection once; mining damage, rock destruction and enemy kills do not award
the new harvest score. Combat should create useful access or safety.

Preserve legacy scores under their original meaning and keep the new record
separately labeled/versioned. The intended scoring change remains unimplemented
until its code round and migration tests pass.

## D6: preserve earned progress without freezing design

Retain existing purchased ownership for the first gameplay milestones and test
fresh, partial and completed profiles. No silent reset, renamed-ID crash or
relabeling of an old score as a new score. Canonical normal rules must not inherit
old hidden range sliders. Preserve presentation/accessibility settings; explicitly
label balance-changing assistance/custom rules if retained.

The review's preference for the existing six upgrades is provisional, not proof
that they provide replayability. Keep ownership compatible, but allow deliberate
rebalancing or a justified later redesign with a migration. Defer new horizontal
unlocks/run-upgrade catalogues until playtesting identifies that specific need.

## D7: controls and contact consequences before harder enemies

Compare stop-to-aim with movement-independent assisted aiming, initially retaining
held firing. Give spawning actual travel direction when aim is separated. Fix
active-player press/release/cancel rebinding and centralize accepted damage and
protected-contact behaviour. Test continuing overlap when protection expires.

Cannon destruction of rocks is a candidate meaningful trade-off only if predictable
and controllable. It is not automatically good because it exists. Assess it with
the aiming comparison; test autofire only if held fire adds no useful decision.
Do not polish a long tutorial before settling these rules.

## D8: small scope and bounded execution

Retain Flutter/Flame, offline/mobile-first scope, one sector, cosmetic ship options,
automatic mining and tractor collection. Start with pursuer plus charger; a third
role or boss must earn its complexity later. Define live/pending entity budgets,
pickup cleanup and real recovery windows before increasing density. Split the
harvest/encounter milestone into accounting/resources and combat sub-rounds.

Keep camera/background work already present. Integrate a small coherent art set
with playable changes, inspecting silhouettes at phone size. Defer multiplayer,
backend/accounts, cloud saves, native stores, large crafting/economy systems,
engine/framework migration and new decorative background technology.

## D9: local workspace failure is not repository failure

Current local command transport fails; the cause and recovery time are unknown.
GitHub connector access remains usable. Do not assume uploads are corrupt, all
files are lost, or every tool is broken. Do not retry expensive extraction until
a cheap workspace probe succeeds. Avoid repeated broad audits and duplicate
multi-gigabyte uploads.

Documentation-only edits may proceed directly through GitHub with pinned baseline,
reviewed remote changes and verified publication. While local execution is down,
mark local lint, link scanning, patch roundtrip and artifact creation NOT RUN;
do not invent those results to satisfy the ordinary handoff procedure. Git retains
the prior and new source trees; no recovery download is required from Ben.
This is a narrow exception to the local packaging steps in WORKFLOW.md, not a
waiver of required repository checks or executable-code validation.

Complex source/SDK changes still need a healthy execution environment. Use the
working WSL/Copilot or available CI path when local execution cannot be recovered;
record external results against their exact source and SDK. Do not claim a healthy
CI configuration or promise local browser access without testing it. Code written,
tests written, tests run, release built and game playtested are separate states.
