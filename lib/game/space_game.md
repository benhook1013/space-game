# space_game.dart

Main FlameGame subclass managing world setup, state transitions and the update loop.

## Responsibilities

- Preload assets via the central registry before entering gameplay.
- Configure the parallax background, set up a fixed-resolution camera that
  follows the player, and register component spawners.
- Spawn the player and register enemy or asteroid generators.
- Provide small bullet, asteroid, enemy and mineral pickup pools to limit allocations.
- Maintain `GameState` values (`menu`, `playing`, `paused`, `gameOver`)
  and toggle overlays.
- Route joystick, button and keyboard input to the player component.
- Handle keyboard shortcuts such as `Escape` or `P` for pause, `M` for mute,
  `Enter` to start or restart from the menu or game over, `R` to restart at any
  time, `Q` to return to the menu from pause or game over, `Esc` to return to the
  menu from game over, and `H` to show or hide the help overlay (`Esc` also
  closes it).
- Expose helpers to pause, resume or return to the menu.
- Drive the update cycle while delegating work to components and services.
- Persist and load the high score through `StorageService`.
- Exposes `ValueNotifier<int>`s for the current score, minerals, health and
  persisted high score so Flutter overlays can render values without touching
  the game loop.
- Provide access to `AudioService` for playing sound effects and toggling mute.
- Offers a method to reset the saved high score.

See [../../PLAN.md](../../PLAN.md) for the roadmap.
