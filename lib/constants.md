# constants.dart

Holds tunable values and configuration numbers used across the game.

- Group constants by feature (player, enemy, asteroid, UI, etc.).
- Use descriptive names like `playerSpeed` or `asteroidSpawnRate`.
- Store only gameplay tuning values here; avoid scattering "magic numbers" in code.
- Expose values as `const` when possible so the compiler can optimise them.

See [../PLAN.md](../PLAN.md) for the authoritative roadmap.
