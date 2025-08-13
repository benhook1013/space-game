# EnemyComponent

Basic foe that drifts toward the player.

## Behaviour

- Spawns at screen edges and moves toward the player ship.
- Damages the player on contact and is destroyed when hit by a bullet.
- Sprites resolved through `assets.dart`; speeds and hit points from `constants.dart`.
- Uses `CircleHitbox` or `RectangleHitbox` depending on art.
- Mixes in `HasGameRef<SpaceGame>` for access to global state.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
