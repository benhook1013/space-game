# BulletComponent

Short-lived projectile fired by the player.

## Behaviour

- Travels in a straight line from the player's ship, matching its current
  orientation.
- Removed on impact or when it exits the screen.
- Uses sprite from `assets.dart` and speed from `constants.dart`.
- Awards score on impact using values from `constants.dart`.
- Reused through a simple object pool managed by `SpaceGame`.
- Uses a `CircleHitbox` and `HasGameRef<SpaceGame>`.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
