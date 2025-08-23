# AsteroidComponent

Neutral obstacle that can be mined for score.

## Behaviour

- Spawns randomly and drifts across the play area.
- Destroyed by bullets or mining action; awards score pickups.
- Uses sprites from `assets.dart` and numbers from `constants.dart`.
- Awards `Constants.asteroidScore` points when destroyed.
- Consider small object pool to reuse instances.
- Uses `CircleHitbox` and `HasGameRef<SpaceGame>`.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
