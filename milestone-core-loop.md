# 🎯 Milestone: Core Loop

Basic gameplay loop with movement, shooting and a simple enemy.
See [PLAN.md](PLAN.md) for overall project goals and
[TASKS.md](TASKS.md) for the consolidated backlog.

## Tasks

- [x] Player ship moves using an on-screen joystick or keyboard (WASD).
- [x] Ship fires bullets and destroys a basic enemy type on collision.
- [x] Random asteroids spawn and can be mined for score.
- [x] Destroying enemies awards score.
- [x] Game states: **menu → playing → game over** with quick restart via overlays
      and a `GameState` enum.

## Design Notes

- Use Flame's `JoystickComponent` and `ButtonComponent` for touch controls.
- Keyboard input uses `KeyboardListenerComponent`.
- Components mix in `HasGameReference<SpaceGame>` and use simple hit boxes.
- Timer-based spawners generate enemies and asteroids.
- Consider small object pools for bullets, asteroids and enemies to limit garbage.

## Next Steps

- [x] Spawn enemy groups in timed waves.
- [x] Equip the player with an auto-firing mining laser for nearby asteroids.
- [x] Drop minerals from mined asteroids and track the currency.
- [x] Auto-aim the main weapon at the closest enemy.
- [ ] Outline a mineral-based upgrade system for weapons and ship systems.
