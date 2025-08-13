# 🎯 Milestone: Core Loop

Basic gameplay loop with movement, shooting and a simple enemy.
See [PLAN.md](PLAN.md) for overall project goals and
[TASKS.md](TASKS.md) for the consolidated backlog.

## Tasks

- [ ] Player ship moves using an on-screen joystick or keyboard (WASD).
- [ ] Ship fires bullets and destroys a basic enemy type on collision.
- [ ] Random asteroids spawn and can be mined for score.
- [ ] Game states: **menu → playing → game over** with quick restart via overlays
      and a `GameState` enum.

## Design Notes

- Use Flame's `JoystickComponent` and `ButtonComponent` for touch controls.
- Keyboard input uses `KeyboardListenerComponent`.
- Components mix in `HasGameRef<SpaceGame>` and use simple hit boxes.
- Timer-based spawners generate enemies and asteroids.
- Consider small object pools for bullets and asteroids to limit garbage.
