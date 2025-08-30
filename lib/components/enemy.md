# EnemyComponent

Basic foe that drifts toward the player.

## Behaviour

- Spawns at screen edges and moves toward the player ship.
- Damages the player on contact and has a single health point.
- Destroyed when hit by a bullet, awarding score on defeat.
- Sprites resolved through `assets.dart`; speeds and hit points from `constants.dart`.
- Awards score when destroyed, using `Constants.enemyScore`.
- Uses `CircleHitbox` or `RectangleHitbox` depending on art.
- Mixes in `HasGameRef<SpaceGame>` for access to global state.
- Uses a small object pool to reuse instances.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
