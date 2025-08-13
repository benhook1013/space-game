# game/

Core game class and shared systems.

- `space_game.dart` will extend `FlameGame` and drive the main loop.
- Owns small helpers for input, collisions, spawners and scoring.
- Tracks state transitions with a `GameState` enum and manages overlays.
- Uses `CameraComponent` with a `FixedResolutionViewport` to keep a
  consistent logical resolution.
- Timer-based spawners generate enemies and asteroids.
- Keep this layer lean and delegate work to components or services.

See [../../PLAN.md](../../PLAN.md) for the broader roadmap.
