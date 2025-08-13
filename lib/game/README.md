# game/

Core game class and shared systems.

- `space_game.dart` will extend `FlameGame` and drive the main loop.
- Owns small helpers for input, collisions, spawners and scoring.
- Tracks state transitions with a `GameState` enum and manages overlays.
- Uses `CameraComponent` with a `FixedResolutionViewport` to keep a
  consistent logical resolution.
- Timer-based spawners generate enemies and asteroids.
- Keep this layer lean and delegate work to components or services.

## Responsibilities

- Load assets via a central registry before starting play.
- Spawn the player and register component spawners.
- Maintain `GameState` values (`menu`, `playing`, `gameOver`) and swap
  overlays accordingly.
- Route input from joystick, buttons or keyboard to the player component.

## Planned Files

- `space_game.dart` – main game class.
- `game_state.dart` – enum describing the game's phases.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
