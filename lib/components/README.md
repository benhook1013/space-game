# components/

Gameplay entities and reusable pieces.

- Includes player, enemy, asteroid and bullet components.
- Each extends a Flame component and mixes in `HasGameRef<SpaceGame>`
  when it needs game context.
- Use simple hit boxes like `CircleHitbox` or `RectangleHitbox` with
  `HasCollisionDetection` on the game.
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
  damage pulses, and awards score on each hit.
- [MiningLaserComponent](mining_laser.md) – auto-targets and mines nearby
  asteroids with a widening pulse beam.
- [StarfieldComponent](starfield.md) – procedural three-layer background with
  parallax motion.

## Planned Components

None at this time.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
