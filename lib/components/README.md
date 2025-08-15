# components/

Gameplay entities and reusable pieces.

- Includes player, enemy, asteroid and bullet components.
- Each extends a Flame component and mixes in `HasGameRef<SpaceGame>`
  when it needs game context.
- Use simple hit boxes like `CircleHitbox` or `RectangleHitbox` with
  `HasCollisionDetection` on the game.
- Pull tunable values from `constants.dart` and asset references from
  `assets.dart`.
- Consider small object pools for frequently spawned objects to reduce
  garbage collection.
- Give components deterministic IDs to support future multiplayer sync.
- Update movement and timers using the `dt` value for frame-rate independence.

## Implemented Components

- [PlayerComponent](player.md) – moves via joystick or keyboard, fires bullets
  and tracks health.
- [EnemyComponent](enemy.md) – drifts toward the player and is destroyed on
  bullet impact.
- [BulletComponent](bullet.md) – short-lived projectile destroyed on hit or
  when leaving the screen.
- [AsteroidComponent](asteroid.md) – floats randomly and awards score when
  destroyed.

## Planned Components

None at this time.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
