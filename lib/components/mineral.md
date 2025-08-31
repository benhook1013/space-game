# MineralComponent

Collectible pickup dropped by destroyed asteroids.

## Behaviour

- Spawns at the asteroid's position when it is destroyed.
- Grants `value` minerals to the player upon collision and then disappears.
- Uses the `mineral.png` sprite from `assets.dart` and values from
  `constants.dart`.
- Instances are pooled by `SpaceGame` and tracked in `mineralPickups`.
- When inside the player's magnetic field, drifts toward the ship for easier
  collection.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
