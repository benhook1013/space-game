# game/

Core game class and shared systems.

- `space_game.dart` will extend `FlameGame` and drive the main loop.
- Owns helpers for world/scene management, input, collisions, spawners and
  scoring.
- Tracks state transitions with a `GameState` enum and manages overlays.
- Uses the default camera viewport so the game fills the available
  browser window.
- Timer-based spawners generate enemies and asteroids.
- Input uses Flame's `JoystickComponent`, `ButtonComponent` and
  `KeyboardListenerComponent`.
- Hooks exist for resource mining, inventory, networking and save/load in later
  milestones.
- Keep this layer lean and delegate work to components or services.

## Responsibilities

- Load assets via a central registry before starting play.
- Configure the world, including the parallax starfield background and
  camera.
- Spawn the player and register component spawners.
- Maintain `GameState` values (`menu`, `playing`, `gameOver`) and swap
  overlays accordingly.
- Schedule the update tick and other timers.
- Route input from joystick, fire button or keyboard to the player component.

## Planned Files

- [space_game.dart](space_game.md) – main game class.
- [game_state.dart](game_state.md) – enum describing the game's phases.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
