# BulletComponent

Short-lived projectile fired by the player.

## Behaviour

- Travels in a straight line from the player's ship.
- Destroyed on impact or after a brief lifetime.
- Uses sprite from `assets.dart` and speed from `constants.dart`.
- Awards score on impact using values from `constants.dart`.
- Reused through a simple object pool managed by `SpaceGame`.
- Uses `RectangleHitbox` or `CircleHitbox` and `HasGameRef<SpaceGame>`.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
