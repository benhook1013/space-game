# AsteroidComponent

Neutral obstacle that can be mined for score and minerals.

## Behaviour

- Spawns randomly and drifts across the play area.
- Destroyed by repeated bullet or mining laser hits. Each hit awards score and
  drops a mineral pickup worth `Constants.asteroidMinerals` at a random spot
  within `Constants.mineralDropRadius` of the asteroid.
- Uses sprites from `assets.dart` and numbers from `constants.dart`.
- Starts with 4–6 health and grants `Constants.asteroidScore` points per hit.
- Uses a small object pool to reuse instances.
- Uses `CircleHitbox` and `HasGameReference<SpaceGame>`.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
