# MineralComponent

Collectible pickup dropped by destroyed asteroids.

## Behaviour

- Spawns at the asteroid's position when it is destroyed.
- Grants `value` minerals to the player upon collision and then disappears.
- Uses the `mineral.png` sprite from `assets.dart` and values from
  `constants.dart`.
- Instances are pooled by `SpaceGame` and tracked in `mineralPickups`.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
