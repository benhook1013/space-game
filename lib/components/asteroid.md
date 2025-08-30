# AsteroidComponent

Neutral obstacle that can be mined for score.

## Behaviour

- Spawns randomly and drifts across the play area.
- Destroyed by repeated bullet or mining hits; awards score pickups each time.
- Uses sprites from `assets.dart` and numbers from `constants.dart`.
- Starts with 4–6 health and grants `Constants.asteroidScore` points per hit.
- Uses a small object pool to reuse instances.
- Uses `CircleHitbox` and `HasGameRef<SpaceGame>`.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
