# AudioService

Lightweight wrapper around `flame_audio`.

## Responsibilities

- Preload sound effect clips during game startup.
- Play one-shot effects for actions like shooting or explosions.
- Expose a mute toggle and master volume persisted via `StorageService`.
- Provide simple methods like `playShoot()`, `playExplosion()` and
  `stopAll()` to halt loops.
- Reuse the shoot sound via a web-only `AudioPool` to avoid network
  fetches on rapid fire.

See [../../PLAN.md](../../PLAN.md) for polish goals.
