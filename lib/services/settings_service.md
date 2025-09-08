# SettingsService

Stores tweakable UI scales, gameplay ranges and performance tuning values with
persistence.

## Responsibilities

- Hold `ValueNotifier`s for HUD, minimap, text and joystick scales.
- Track targeting, Tractor Aura and mining ranges.
- Expose starfield tile size for performance scaling.
- Persist changes via `StorageService` and reload on startup.
- Provide `reset()` to restore default values for all settings.

See [../../PLAN.md](../../PLAN.md) for polish goals.
