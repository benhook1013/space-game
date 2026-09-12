# Space Miner design

Updated 12 September 2026. [PLAN.md](PLAN.md) owns scope and sequencing;
[TASKS.md](TASKS.md) tracks implementation. This document separates the inspected
prototype from intended changes. No gameplay change is implemented by this
planning round.

## Current implementation and evidence

The review baseline is commit
`6b93b7d551bd11e995c71a1620b2b587a471cfe8`.
Useful module references are [game](lib/game/README.md),
[components](lib/components/README.md), [UI](lib/ui/README.md),
[services](lib/services/README.md), [assets](assets/README.md) and
[tests](test/README.md). Older module prose may describe intent; source and actual
execution take precedence for claims about current behaviour.

`SpaceGame` uses Flame components and delegates to lifecycle, flow, input,
overlay, targeting, scoring, upgrade and other helpers. Flutter overlays and
ValueNotifiers connect the interface to game state. Retain that lightweight
composition. Keep constants and asset paths centralized, movement time-based,
and game-state changes separate from rendering.

The following source observations inform the redesign, not a claim of a
completed playtest:

- `PlayerInputBehavior._processInput` normalizes nonzero input and sets facing
  from movement. `shoot` uses current facing. `AutoAimBehavior.update` stops
  assisting while the player moves; firing requires held input.
- The spawners derive ahead-of-player placement from `player.angle`, which is
  unsuitable as travel direction if weapon aim becomes independent.
- `ControlManager._buildFireButton` binds press, release and cancellation;
  `LifecycleManager.onStart` rebinds only press and release on replacement.
- `BulletComponent.onCollisionStart` destroys an asteroid through `destroy`,
  without mineral drops. `AsteroidComponent.takeDamage` produces ore and awards
  the old score before collection; `destroy` also awards the old asteroid score.
- `MineralComponent` moves toward the player within tractor range but has no
  lifetime or offscreen-cleanup policy in that component. Pool reuse alone is
  not an active-count or memory bound.
- Existing purchases persist while the mineral wallet resets each run. Normal
  gameplay currently consumes persisted range settings. Damage flashing is not
  a post-hit immunity gate in the previously inspected damage path.

See [the review record](docs/development/rounds/002-review-plan.md) for provenance
and what remains unverified. Dominant strategies, touch faults, pacing and
resource growth require executable tests, not just source inspection.

## Intended controls

Keep automatic mining. Compare stop-to-aim with movement-independent assisted
weapon aiming, initially with held firing in both. Do not impose twin sticks or
autofire before assessing input burden and deliberate cease-fire opportunities.
Test whether analogue joystick magnitude improves fine positioning; do not
confuse keyboard diagonal normalization with necessarily desirable touch input.

If aim is decoupled, represent actual movement/travel independently from gun
facing. Spawn placement and navigation must use movement, not whichever target
the cannon selects. Define the stationary fallback explicitly. Weapon visuals,
projectile origins and targeting feedback must match the chosen aim.

Use one binding path for press/release/cancel when the active player changes.
Clear held inputs on restart, pause/focus loss and relevant overlay transitions.
Test touch cancellation and keyboard release across each transition.

Cannon destruction of ore is an existing rule to evaluate, not a sacred design
pillar. Keep it only if the player can predict and intentionally manage the
firing line. If it mostly feels like assisted aiming confiscates resources,
change it. If holding fire is always correct after that, test autofire rather
than retaining a pointless held button. Experimental alternatives should be
small controlled previews/tests, not permanent public tuning infrastructure.

## Intended damage and contact contract

Centralize hit acceptance. Only an accepted hit changes health, starts protection
and produces accepted-hit feedback. Define separate handling for contacts while
protected, outside play or after death. An immunity check added after unconditional
obstacle removal would permit free ramming; move consequences behind the policy.

Protected contact must not automatically delete enemies or asteroids. Specify
separation/overlap behaviour and check continuing overlap when protection expires:
a start-only collision callback must not create permanent safe overlap. Verify
clustered contacts, protection timing, pause/resume, simultaneous death events
and restart reset. The initial protection duration is a tuning parameter, not
an established balance fact.

## Intended ore accounting and records

Use one resource with two measurements:

```text
Collect a pickup once:
  wallet += pickup.value
  collectedThisRun += pickup.value

Buy an upgrade:
  wallet -= upgrade.cost

Primary run score, or experimental quota progress:
  collectedThisRun
```

Mining, shooting a rock or killing an enemy must not increase the new harvest
score. Combat can create access to ore and appear in a separate results statistic.
Do not count generic wallet adjustments as harvest: purchasing is not negative
collection, and debug grants are not earned score. Make pickup consumption
idempotent across collision/removal events and disallow negative balances.

Both counters reset for a new run; spending does not reverse collected progress.
A quota, when experimentally enabled, completes once when cumulative collection
reaches its target. Handle success explicitly rather than simulating player death.
If death and the target occur in the same simulation step, choose, document and
test one deterministic outcome instead of granting both results.

Keep the existing high score under its existing key as a legacy record. A harvest
score needs a separately versioned/labeled record; old kill/mining scores must not
be silently relabeled or numerically compared with it. Preserve purchased IDs,
selected ship and presentation preferences. Tolerate unknown saved IDs and test
failed storage writes. A save migration is explicit and tested, not a reset of
preferences to hide incompatible data.

## Progression and normal rules

Retain the six owned upgrades during the first implementation milestones.
Their existence is evidence of implemented progression, not proven motivation or
replayability. Test fresh, partially upgraded and fully upgraded fixtures.
Preservation of earned ownership does not prohibit deliberate, documented
rebalancing with regression tests; a larger redesign needs a migration decision.

Use canonical balance values for normal play before applying earned upgrades.
Removing sliders from the UI is insufficient if stat getters still read the old
saved tuning values. Keep volume, text/UI scale and readability/accessibility
controls. If balance-changing assist/custom rules are retained, label their use
and keep their results distinct; do not silently treat them as normal records.
Do not add a competitive backend or an elaborate anti-cheat system.

No new horizontal-unlock catalogue or per-run upgrade tree is presumed. If the
completed profile lacks worthwhile decisions, first distinguish control, resource,
encounter and progression problems. New build choices require real opportunity
costs and must not collapse into one universally optimal purchase order.

## Resource fields and collection

Seed a small nearby field at the start. Use deliberately understandable sparse
and rich patches to test routing and exposure before increasing procedural variety.
Mining at range and collecting closer to a rock should create choices without
compulsory stationary waiting. Partial harvesting and leaving/returning for drops
are candidate behaviours to preserve where they are understandable.

Test base and upgraded ship speed against tractor pull speed, collection range
and pickup collision behaviour. Faster flight need not collect everything
automatically, but must not make the upgrade feel broken without explanation.
Do not change several ranges and speeds at once and then call the outcome a
control-scheme experiment.

## Encounters and bounded simulation

Start with a pursuer and a telegraphed charger. A charger must visibly commit to
a direction and offer a recoverable miss, not secretly retarget during an attack
that was presented as committed. Test distinct player responses before adding a
ranged enemy or boss. Stop presenting a large one-hit sprite as meaningful boss
content; retaining its artwork does not require retaining that role.

Pressure/recovery scheduling must account for existing threats. A pause in
spawning is not recovery if accumulated pursuers still deny every resource route.
Use viewport-aware warnings and time-to-contact on phone and desktop rather than
blindly retaining a world-unit spawn radius. Define a bounded long-tail difficulty
policy rather than requiring unavoidable hits or limitless health inflation.

Before adding density, set budgets for live and pending enemies, rocks, bullets
and pickups. Do not save skipped spawns in a hidden debt that creates a later
burst. Define age/distance cleanup with enough margin for intentional return
routes; do not silently delete nearby valuable pickups just to satisfy a cap.
Test removal notifications, pooled-object reset, spatial-grid membership and
repeat restarts. Record active counts over an extended session on actual devices.

## State, rendering and assets

Extend existing lifecycle/state and overlay paths. Reset score, input, protection,
encounter phase and entity membership consistently. Ensure pause also freezes
warnings, cooldowns and intended timers. No new ECS, general simulation engine,
network layer or content framework is needed for these milestones.

Keep the existing camera, minimap and starfield. Improve player/enemy silhouettes,
weapon direction, pickup readability and hit/collection feedback at actual phone
size. Integrate art with the asset registry and manifests; respect
[ASSET_GUIDE.md](ASSET_GUIDE.md) and [ASSET_CREDITS.md](ASSET_CREDITS.md).
An illustrated or vector-style sample is a test of readability, not the final
style by decree. Add expensive effects only after measuring the release build.

## PWA and validation

Target a release web artifact at the intended `/space-game/` base path. Repair
custom-cache ownership and critical precache failure behaviour; preserve a working
offline version when an update fails. Tie published output to validated source.
Test actual offline startup and update transitions, not just a mocked worker.

Technical invariants belong in unit/component/widget/browser tests. Control
quality, readable threats, replay and preferred ending require playtests on
keyboard and real touch devices. Use controlled layouts and restored profiles;
a seeded spawner alone does not make all game randomness deterministic.
Record limitations and failures, not just successful examples.
