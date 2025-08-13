# PlayerComponent

Controllable ship for the player.

## Behaviour

- Moves via on-screen joystick or WASD keys.
- Fires `BulletComponent`s when the shoot button or space bar is pressed.
- Tracks health and triggers game over when depleted.
- Pulls sprites from `assets.dart` and tuning values from `constants.dart`.
- Uses `CircleHitbox` and `HasGameRef<SpaceGame>`.

See [../../PLAN.md](../../PLAN.md) for core loop goals.
