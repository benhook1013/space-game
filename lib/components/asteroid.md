# AsteroidComponent

Neutral obstacle that can be mined for score and minerals.

## Behaviour

- Mining laser pulses damage asteroids, dropping a mineral pickup worth
  `Constants.asteroidMinerals` at a random spot within
  `Constants.mineralDropRadius` for each point of damage.
- Shots from the main cannon destroy asteroids instantly without dropping
  minerals, but still award `Constants.asteroidScore` points.
- Uses sprites from `assets.dart` and numbers from `constants.dart`.
- Starts with 4–6 health and grants `Constants.asteroidScore` points per hit.
- Uses a small object pool to reuse instances.
- Uses `CircleHitbox` and `HasGameReference<SpaceGame>`.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
