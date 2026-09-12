# Round 002: adversarial review and revised game plan

Date: 12 September 2026. Documentation-only round, prepared through the GitHub
connector while local command transport is unavailable. This file records the
review and intended publication, not advance proof that a PR merged. The PR,
commit and current branch ref provide the publication result.

## Baseline and source of feedback

Remote `main` was read at
`6b93b7d551bd11e995c71a1620b2b587a471cfe8`, tree
`6a7f0e6a134a474222f610bfd69c7f34697b2b15`.
This verifies that Round 001 and delegated publication are already on `main`,
superseding its initial handoff's pending-integration wording.

Ben supplied `Pasted text.txt`, headed "Verdict: prefer an improved endless game
first; substantially revise the expedition proposal". The independent reviewer
reported reading this same revision, but did not build or play the game. Its
recommendations are design input, not measured player preferences or repository
authority. This document is the implementing assistant's disposition, not a
verbatim reproduction or a claim that Ben personally selected every design detail.

## Findings checked through the connector in this round

- [PlayerInputBehavior](../../../lib/components/player_input_behavior.dart):
  nonzero input is normalized, movement sets target facing, shots use current
  facing and repeat while held. [AutoAimBehavior](../../../lib/components/auto_aim_behavior.dart)
  returns while moving.
- [ControlManager](../../../lib/game/control_manager.dart) binds press/release/
  cancellation. [LifecycleManager](../../../lib/game/lifecycle_manager.dart)
  rebinds press/release only when replacing the player. The callback mismatch is
  confirmed in source; actual stuck-fire reproduction is still outstanding.
- [BulletComponent](../../../lib/components/bullet.dart) calls asteroid `destroy`.
  [AsteroidComponent](../../../lib/components/asteroid.dart) destroys without ore
  and awards old score, while mining damage produces pickups and old score before
  collection. An intentional combat/mining trade-off is plausible, not proven fun.
- [MineralComponent](../../../lib/components/mineral.dart) has attraction but no
  lifetime or offscreen-cleanup policy in the component. Measure session growth
  and audit pool/removal paths before claiming a reproduced memory/performance bug.

The review also identifies spawner direction coupling, persisted range effects,
contact immunity gaps, the finite persistent catalogue and deployment/cache
issues. Those agree with the earlier source audit at the unchanged gameplay
baseline. They remain queued findings, not fixes or new runtime test passes.

## Disposition

### Accept

Prove harvesting/collection under pressure before choosing the ending. Use the
improved endless game as the initial baseline and compare it with a simple
cumulative-ore ending on matched mechanics/profiles. Retain the engine, one-sector
scope, cosmetic ship choice, automatic mining and tractor collection.

Settle movement/aim/firing and damage consequences before more demanding threats.
Start with a nearby field and functional cues, not a polished scripted tutorial.
Start enemy differentiation with pursuer plus charger. Bound active/pending
entities and define pickup cleanup before adding density.

Make collected ore the primary score and track spending separately. Preserve
old purchased ownership and the meaning of old high scores. Isolate canonical
normal rules from persisted prototype tuning without removing accessibility.

### Accept with qualifications

Keeping the existing six upgrades is a lower-risk first step, not proof that they
supply motivation or enough replay. They are an implemented progression system,
not a demonstrated successful retention hook. Preserve earned ownership, but do
not freeze flawed numbers forever or forbid a later explicit migration.

Cannon destruction of rocks may create useful firing decisions, but may instead
punish players for automatic target selection. Test predictability and deliberate
cease-fire. Do not romanticize an accidental rule because it exists in source.

The review's second gameplay round contains accounting, layouts, cleanup, a new
enemy and pacing. Split it into G2a and G2b so regressions remain diagnosable.
Controlled comparisons should be small and retired after the decision, not become
a public rules editor or a permanent two-mode support burden.

For endless play, cumulative collection can reward duration as well as skill.
Check long-session repetition and completed-profile decisions; a numeric score
alone does not establish a finished game. Preserve the possibility that a finite
objective wins the experiment.

### Reject as requirements; defer as possibilities

Mandatory extraction, boss, third enemy, fixed 8-12-minute sessions, six to eight
run upgrades, replacement permanent progression and a horizontal-unlock catalogue.
No new currency, mining heat, cargo system or harvesting stance before simpler
spatial decisions are tested. A useful quota would not justify these automatically.

## Small experiments and stopping rules

1. Same small encounter on keyboard and real touch: compare stop-to-aim against
   movement-independent assisted aim with held fire. Include a valuable rock in
   the firing line and cancel touch after restart. Observe intentional decisions
   versus input workarounds; change the control/resource rule if it is confusing.
2. Sparse/easier and rich/exposed patches with two threats: deliberately try
   stationary farming, unchanged-direction kiting, avoiding all fights and active
   clearing. Observe harvest, damage, dropped ore and route changes. If a repetitive
   low-risk method is equally effective with fewer decisions, repair layout or
   pressure. Successful skilled avoidance alone is not an exploit.
3. Same improved game with and without a cumulative-ore ending: restore identical
   profiles and rotate order where practical. Observe useful direction, satisfying
   versus premature stopping and voluntary retry. Choose one mode. If both are
   boring, revise the shared loop rather than adding a finale.
4. Fresh, partial and complete upgrades: check that winning/successful harvesting
   does not require grind and completed power does not remove all decisions.
   Reopen progression only for an observed problem; preserve legacy records.
5. Technical stress: clustered and continuing contacts, paused warnings, input
   cancellation, repeat restarts, abandoned pickups, bounded counts, offline
   boot and failed updates. Passing these proves tested correctness, not enjoyment.

These are qualitative falsification tests, not validated thresholds or statistical
claims. Seed all relevant random decisions or use controlled fixtures; one seeded
spawner does not make every outcome repeatable.

## Documentation changes and exclusions

Update PLAN, DESIGN and TASKS to the reviewed direction instead of preserving
competing active roadmaps. Record durable decisions and dated environment status.
Correct the historical Round 001 log's publication status with an addendum.
Old prototype details remain in Git history and module/milestone documentation.

No Dart, tests, assets, SDK pins, dependency constraints/lockfile, bootstrap,
service-worker code or CI/deployment configuration changes in this round.
No SDK/dependency restoration, source build or game playtest is performed here.

## Validation limits and publication procedure

A basic local command returned `TransportTimeoutError`; its cause is unknown.
Local Markdown lint, automated link scanning, Git whitespace check, helper tests,
patch roundtrip and recovery-archive generation are NOT RUN. Earlier reported
passes are not reused as new results. This is the narrow documentation-only
connector exception recorded in DECISIONS; no executable-code gate is waived.

Read pinned source, inspect the complete remote change set, verify that changed
paths are documentation only, and use the normal required PR route with an exact
expected head. Respect repository-required checks/reviews. Read back `main` and
its tree before reporting publication. Git history retains both source versions;
Ben need not download a diagnostics or recovery bundle.

Next implementation: T0 supplied-SDK/support restoration and compatibility in a
healthy execution environment, bounded T1 release safety, then G1, G2a/G2b and G3.
