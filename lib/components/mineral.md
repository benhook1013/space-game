# MineralComponent

Collectible pickup dropped by destroyed asteroids.

## Behaviour

- Spawns near the asteroid for each point of damage it takes.
- Grants `value` minerals to the player upon collision and then disappears.
- Uses the `mineral.png` sprite from `assets.dart` and values from
  `constants.dart`.
- Instances are pooled by `SpaceGame` and tracked in `mineralPickups`.
- When inside the player's Tractor Aura, drifts toward the ship for easier
  collection.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
