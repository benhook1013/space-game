# components/

Gameplay entities and reusable pieces.

- Includes player, enemy, asteroid, bullet, mineral pickup and magnet
  components.
- Each extends a Flame component and mixes in `HasGameReference<SpaceGame>`
  when it needs game context.
- Use simple hit boxes like `CircleHitbox` or `RectangleHitbox` with
  `HasCollisionDetection` on the game.
- Shared mixins like `DebugHealthText` provide common behaviours such as
  rendering health values while in debug mode.
- Pull tunable values from `constants.dart` and asset references from
  `assets.dart`.
- Bullet, asteroid and enemy components use small object pools to reduce
  garbage collection, and unit tests confirm pooled instances are reused.
- Give components deterministic IDs to support future multiplayer sync.
- Update movement and timers using the `dt` value for frame-rate independence.

## Implemented Components

- [PlayerComponent](player.md) – moves via joystick or keyboard, fires bullets
  with a short cooldown and tracks health.
- [EnemyComponent](enemy.md) – drifts toward the player with a single health
  point and awards score when defeated.
- [BulletComponent](bullet.md) – short-lived projectile that deals one damage
  and is destroyed on hit or when leaving the screen.
- [AsteroidComponent](asteroid.md) – floats randomly, requires four to six
  damage pulses and drops a mineral pickup for each point of damage.
- [MiningLaserComponent](mining_laser.md) – auto-targets and mines nearby
  asteroids with a widening pulse beam.
- [MineralComponent](mineral.md) – collectible dropped whenever an asteroid is
  damaged that increases the player's mineral total when picked up.
- [MineralMagnetComponent](mineral_magnet.md) – blue aura that follows the
  player and draws nearby mineral pickups toward the ship.
- [Starfield](starfield.md) – parallax background built with Flame's
  `ParallaxComponent`.

## Planned Components

None at this time.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
