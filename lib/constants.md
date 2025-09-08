# constants.dart

Holds tunable values and configuration numbers used across the game.

- Group constants by feature (player, enemy, asteroid, UI, etc.).
- Use descriptive names like `playerSpeed` or `asteroidSpawnRate`.
- Store only gameplay tuning values here; avoid scattering "magic numbers" in code.
- Include scoring values like `enemyScore` and `asteroidScore`
  so they are easy to tweak.
- Include timing values such as `bulletCooldown` and spawn intervals so
  behaviour like fire rates and spawn rates can be adjusted centrally.
- Use a global `spriteScale` for the default 3× enlargement, with per-entity
  scale offsets like `playerScale` layered on top.
- Expose values as `const` when possible so the compiler can optimise them.
- Centralise visual colours such as range ring and Tractor Aura colours.

See [../PLAN.md](../PLAN.md) for the authoritative roadmap.
