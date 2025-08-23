# space_game.dart

Main FlameGame subclass managing world setup, state transitions and the update loop.

## Responsibilities

- Preload assets via the central registry before entering gameplay.
- Configure the parallax background, camera and component spawners.
- Spawn the player and register enemy or asteroid generators.
- Maintain `GameState` values (`menu`, `playing`, `gameOver`) and toggle overlays.
- Route joystick, button and keyboard input to the player component.
- Drive the update cycle while delegating work to components and services.
- Persist and load the high score through `StorageService`.
- Exposes `ValueNotifier<int>`s for the current score and persisted high score so
  Flutter overlays can render values without touching the game loop.
- Provide access to `AudioService` for playing sound effects and toggling mute.

See [../../PLAN.md](../../PLAN.md) for the roadmap.
