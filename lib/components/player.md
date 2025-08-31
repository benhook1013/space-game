# PlayerComponent

Controllable ship for the player.

## Behaviour

- Moves via on-screen joystick or WASD keys.
- Fires `BulletComponent`s with a short cooldown when the shoot button or space
  bar is pressed, in the direction the ship is facing.
- Colliding with enemies or asteroids reduces health via `SpaceGame.hitPlayer`
  and briefly flashes the ship red.
- When stationary, periodically rotates to face the nearest enemy within range.
- Collects `MineralComponent`s on contact to increase the mineral counter.
- A blue magnetic aura pulls nearby mineral pickups toward the ship.
- Pulls sprites from `assets.dart` and tuning values from `constants.dart`.
- Uses `CircleHitbox` and `HasGameReference<SpaceGame>`.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
