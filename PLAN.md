# Space Miner plan

Updated 12 September 2026 after the independent adversarial review.
This is the implementation direction, not a claim that the changes below exist
or have been playtested. See [DESIGN.md](DESIGN.md) for behavioural contracts,
[TASKS.md](TASKS.md) for execution order and
[the review disposition](docs/development/rounds/002-review-plan.md) for reasoning.

## Product direction

Build a small, complete, harvest-focused mining-survival game with Flutter and
Flame. Keep the mobile-first, offline-capable browser PWA, desktop keyboard
support, casual tone, automatic mining and tractor collection.

The development baseline remains endless play. Improve the decisions shared by
both possible formats before comparing it with an otherwise identical game
ending at a cumulative ore target. Endless is the lower-change starting point,
not a proven winner. Select one headline release format after that comparison.

The earlier expedition proposal bundled too many untested decisions. Extraction,
a boss, three enemy roles, an 8-12-minute run length, six to eight new run upgrades
and replacement of permanent progression are not release requirements.

The intended moment-to-moment loop is:

```text
Find a promising patch -> mine -> collect exposed pickups -> evade or clear
threats -> decide whether to stay, return for ore or move to another patch.
```

The player should be choosing routes, exposure and firing opportunities, not
waiting for automatic systems to finish. Improving a weak shared loop takes
priority over adding an ending, more unlocks or more decorative systems.

## Minimum complete release

- One sector and one mechanical starting ship; existing sprite choices remain
  cosmetic. A sector need not add new hard world boundaries.
- Nearby opening resources and subsequent placement with understandable choices
  between easier, sparser patches and richer, more exposed patches.
- Automatic mining, tractor collection and a settled keyboard/touch combat
  scheme. Test movement-independent assisted aiming against stop-to-aim before
  selecting the default. Retain held firing for that first comparison.
- A pursuer and one genuinely different threat, initially a telegraphed charger,
  with readable attacks and meaningful recovery opportunities.
- Collected ore as the primary run score, a separate spendable wallet, existing
  purchased upgrades, accurate results, personal bests and quick retry.
- Readable phone-size graphics and feedback, reliable pause/restart, fair contact
  handling, bounded active entities and tested release/offline/update behaviour.

Existing ownership and historical scores must survive. Preserving progress does
not freeze all balance values forever. Test fresh, partial and fully upgraded
profiles; completed progression must still leave an enjoyable game. Do not call
an uninteresting completed catalogue acceptable because more unlocks may follow.

If the matched comparison favours finite play, replace endless continuation with
an explicit quota success/result transition. That decision does not also approve
extraction, a boss or a progression rewrite.

## Scope exclusions

No multiplayer, accounts, cloud saves, backend services, native-store release,
engine migration, generic ECS/content framework, elaborate crafting, galaxy map,
station economy, additional currencies or new procedural background systems.
Do not add cargo weight, mining heat or a harvesting stance without evidence that
simple resource positioning and combat cannot create the necessary choices.

The existing camera, starfield, assets, overlays, services, pools and spatial
query helpers are useful foundations. Extend them rather than replacing them to
fit a genre template. Coherent new ship/enemy/pickup art should accompany relevant
playable rounds; approve a small sample at gameplay size before a wholesale swap.

## Technical baseline before gameplay

T0 establishes an executable baseline on the supplied Linux SDK. Earlier setup
reported Flutter 3.47.4 / Dart 3.13.3 launching, but that is not a passing game
build. The offline dependency bundle has arrived and has not yet been restored.
Local command transport currently times out; see
[ENVIRONMENT.md](docs/development/ENVIRONMENT.md).

Inspect the bundle and actual SDK in a healthy execution environment. Keep the
compatibility migration separate from gameplay; align pins, bootstrap checksums,
lockfile, CI assumptions and docs with the verified version. Prefer minimal
compatible dependency changes. Run analysis, tests and a release build and record
source failures separately from missing packages or artifacts.

T1 is bounded delivery safety: application-scoped cache cleanup, failed critical
precache/update handling, release rather than debug publication, and validation
of the exact artifact/revision published. Do not spend successive rounds building
workflow infrastructure. These repairs do not prove gameplay or device readiness.

## Gameplay milestones

### G1: control and fairness

Outcome: a nearby resource field supports immediate mining and an understandable
encounter on keyboard and touch, including after restart.

Fix damage acceptance and protected-contact consequences, complete fire-button
callback rebinding, and separate actual travel direction from aiming where
needed. Establish normal ranges independent of old persisted tuning settings.
Compare the existing aiming rhythm with movement-independent assisted aiming in
one controlled encounter. Include an asteroid between player and enemy so firing
agency and resource destruction can be assessed together.

Exclude quota, new progression, charger implementation, final art and an elaborate
scripted tutorial. Choose controls from observed usability, not a genre convention.

### G2: worthwhile harvesting under pressure

Outcome: resource routes, collection and combat present observable trade-offs.

Implement collected-ore accounting, preserve old records and purchases, arrange
contrasting resource patches, then introduce the charger and pressure/recovery
scheduling. Put live/pending entity budgets and predictable pickup cleanup in
place before increasing density. Split accounting/resources and encounters into
separate small commits or sub-rounds rather than one large untestable change.

Test stationary farming, unchanged-direction kiting, combat avoidance and active
clearing/collection on fresh and progressed profiles. Skilled evasion can be
legitimate; the problem is an equally productive low-risk strategy with almost
no decisions. Do not make unavoidable damage the remedy.

Exclude a third threat, boss, extraction, new currencies and a run-upgrade tree.

### G3: choose and finish the release format

Outcome: one complete, understandable mode with useful results and repeat play.

Compare endless continuation with a cumulative-ore ending using the same controls,
layouts, encounters and restored starting profiles. The finite version completes
immediately at its target through explicit success handling. No extraction
countdown or changed progression should confound this comparison.

Observe whether the goal gives direction, whether finishing is satisfying or
premature and whether players voluntarily retry. Choose one default; do not ship
two maintained headline modes merely to avoid deciding. Retire comparison-only
code after the decision. If both versions are dull, return to G2.

Then finish opening guidance, coherent art and feedback, results, saves and
release regression/device checks. Do not expand content to conceal failed tests
of the core experience.

## Release acceptance

An unfamiliar player should understand the goal, explain a meaningful choice and
name something to try differently on a later run. This is a qualitative starting
criterion, not a statistically validated measure of enjoyment.

Check keyboard and actual touch devices, fresh and completed progression, normal
and previously tuned settings, interrupted play and repeated restarts. Test
extended sessions for monotonous survival/score inflation as well as resource
accumulation. Record active counts and frame behaviour on representative devices;
do not infer performance from pooling or a desktop-only run.

Build the release, test first load and repeat offline boot, failed updates,
application cache isolation and deployment under the intended base path. Technical
passes and subjective playtest results are different evidence. Neither substitutes
for the other, and no acceptance box is complete merely because this plan exists.

## Working arrangements

Ben delegates implementation and publication to the assistant. Use `main` as the
accepted source of truth; the assistant handles required PRs and merges without
force-pushing or weakening protection. Ben normally pulls and playtests from
`/home/ben/src/space-game`. Routine patch ZIPs and diagnostic downloads are not
required user work. Follow [WORKFLOW.md](WORKFLOW.md) and the latest
[decisions](docs/development/DECISIONS.md), including the documentation-only
connector fallback while local execution is unavailable.

Historical MVP checklists in `milestone-*.md` describe the prototype, not current
release acceptance. Earlier long-form plans remain in Git history; they do not
restore deferred features to the active queue.
