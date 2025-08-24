# PlayerComponent

Controllable ship for the player.

## Behaviour

- Moves via on-screen joystick or WASD keys.
- Fires `BulletComponent`s with a short cooldown when the shoot button or space
  bar is pressed.
- Colliding with enemies or asteroids reduces health via `SpaceGame.hitPlayer`.
- Pulls sprites from `assets.dart` and tuning values from `constants.dart`.
- Uses `CircleHitbox` and `HasGameRef<SpaceGame>`.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
