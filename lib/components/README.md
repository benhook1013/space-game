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

## Planned Components

- `PlayerComponent` – moves via joystick or keyboard, fires bullets and tracks
  health.
- `EnemyComponent` – drifts toward the player and damages on contact.
- `AsteroidComponent` – floats randomly; mining yields score pickups.
- `BulletComponent` – short-lived projectile destroyed on hit or timer.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
