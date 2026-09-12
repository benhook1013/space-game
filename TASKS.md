# Active implementation queue

Updated 12 September 2026. [PLAN.md](PLAN.md) defines the reviewed direction;
[DESIGN.md](DESIGN.md) specifies intended contracts. A checked item records
completed work, not blanket validation of the game. Historical prototype
checklists remain in `milestone-*.md` and Git history.

## Completed and received

- [x] Round 001 process/helper work and delegated publication reached `main`
  through PR #716 at `6b93b7d551bd11e995c71a1620b2b587a471cfe8`.
- [x] Receive Ben's independent adversarial review and record the implementing
  assistant's decisions in round `002-review-plan`.
- [x] Receive split SDK uploads and `space-game-offline-support.zip`. Receipt
  does not mean the dependency bundle has been restored or validated.

## Current execution blocker

A bounded local command retry returned `TransportTimeoutError`. The GitHub
connector still reads the accepted repository. See
[ENVIRONMENT.md](docs/development/ENVIRONMENT.md) for historical SDK progress,
known paths and the limited fallback. Do not request duplicate large uploads
or repeat a broad tool audit. Documentation can proceed through the connector;
code needing execution uses a healthy local/WSL/CI environment.

## T0: SDK compatibility and executable baseline

- [ ] Inspect the support ZIP paths, manifest, payload checksums, restore script,
  source revision, lockfile diff and supplementary SDK cache before execution.
- [ ] Restore public packages into an isolated cache using the supplied exact
  Linux SDK. Regenerate machine-specific package configuration.
- [ ] Establish offline lockfile resolution, analysis, tests and release build
  independently. Record pre-existing source failures and missing artifacts.
- [ ] Migrate all SDK pins, Unix/PowerShell bootstrap versions/checksums and CI
  assumptions together; change dependencies only for demonstrated compatibility.
- [ ] Publish a validated compatibility-only change through repository rules.
  Do not put SDKs, caches, generated builds or credentials into Git.

## T1: release and cache safety

- [ ] Restrict obsolete-cache deletion to this application/deployment namespace.
- [ ] Make missing critical precache resources fail the update rather than
  accept an incomplete shell. Preserve the working offline version.
- [ ] Add executable JavaScript regressions and actual offline/update checks.
- [ ] Replace debug publication with a release build and validate the exact
  source/artifact being published. Keep changes small and separate from gameplay.

## G1: controls, protected contacts and immediate resources

Prerequisite: executable baseline; controlled normal rules and profile fixtures.

- [ ] Isolate normal gameplay values from previously persisted range tuning;
  retain presentation/accessibility settings and test an old tuned profile.
- [ ] Define accepted/rejected contact consequences and visible post-hit
  protection. Test simultaneous hits, ongoing overlap and pause/restart reset.
- [ ] Rebind press, release and cancellation consistently to the active player.
- [ ] Use actual travel direction for placement before changing aiming behaviour.
- [ ] Seed a small nearby mining field and compare stop-to-aim with independent
  assisted aim while holding the remaining encounter rules constant.
- [ ] Test touch magnitude/fine control, cancellation after restart, and a
  valuable rock in the firing line. Record the selected input/resource rule.

Acceptance: keyboard and touch play are understandable; firing stops on
release/cancel; protection does not clear hazards for free; the experiment
selects controls rather than assuming a genre-standard answer.

Exclude quota, new progression, extra threats, final art and scripted tutorial.

## G2a: harvest accounting and resource choices

Prerequisite: G1 controls and contact policy selected and tested.

- [ ] Add idempotent pickup collection that credits wallet and cumulative ore;
  purchases debit only the wallet. Reset both counters for each new run.
- [ ] Make collected ore the primary run score and preserve the old high score
  separately. Test unknown purchased IDs and storage-write failures.
- [ ] Retain purchased ownership and build fresh/partial/complete test profiles.
- [ ] Arrange understandable sparse/easier and rich/exposed resource patches.
- [ ] Define live/pending entity budgets and predictable pickup cleanup before
  increasing density. Test extended sessions and returning for abandoned drops.

Acceptance: uncollected drops and cannon rock destruction give no harvest score;
buying never reverses earned harvest; records and ownership survive migration.

## G2b: pressure and distinct responses

Prerequisite: G2a accounting and bounded resource simulation.

- [ ] Add a telegraphed charger alongside the pursuer, including commitment,
  recovery, pooled-state reset and phone-size cues.
- [ ] Alternate pressure and meaningful recovery while considering live threats;
  use visible-area/time-to-contact fairness and no queued spawn debt.
- [ ] Compare stationary farming, fixed-direction kiting, ignoring enemies and
  active clearing/collection on fresh and completed profiles.
- [ ] Record whether players make routing/collection decisions, not just survive
  input friction. Repair the shared loop if repetitive low-risk farming wins.

Acceptance: the two threats cause different responses and ore routes carry
understandable trade-offs. Legitimate avoidance is not automatically an exploit.

Exclude a third role, boss, extraction, run-upgrade tree and new currencies.

## G3: choose and finish one release mode

Prerequisite: the shared harvesting loop passes the G2 playtests.

- [ ] Compare endless play with the same game ending at cumulative ore quota.
  Use matched layouts/profiles; define success and simultaneous-death policy.
- [ ] Record whether completion adds purpose or interrupts enjoyable play.
  Choose one default and remove comparison-only code; return to G2 if both fail.
- [ ] Finish concise opening guidance, coherent integrated artwork, readable
  feedback/results, personal records and fast reliable retry.
- [ ] Complete real keyboard/touch, fresh/completed profile, focus/pause/restart,
  long-session and release-PWA/offline/update checks; record remaining blockers.

Acceptance: unfamiliar players understand the goal and can explain a choice and
another approach to try. Fully upgraded play remains worthwhile. Tests/builds,
performance observations and enjoyment evidence are reported separately.

## Deferred, not silently scheduled

Extraction, boss, third enemy, fixed 8-12-minute sessions, broad run upgrades,
horizontal unlocks, additional currencies, galaxy/station/crafting systems,
multiplayer, accounts, cloud saves, native stores and new background technology.
Preserving saves does not forbid justified tuning; changing progression requires
an explicit decision and migration rather than silent loss of earned progress.
