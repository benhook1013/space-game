# AudioService

Lightweight wrapper around `flame_audio`.

## Responsibilities

- Preload sound effect clips during game startup.
- Play one-shot effects for actions like shooting or explosions.
- Expose a mute toggle persisted via `StorageService`.
- Provide simple methods like `playShoot()` or `playExplosion()`.

See [../../PLAN.md](../../PLAN.md) for polish goals.
