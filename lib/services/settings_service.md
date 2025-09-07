# SettingsService

Stores tweakable UI scales and gameplay ranges with persistence.

## Responsibilities

- Hold `ValueNotifier`s for HUD, minimap, text and joystick scales.
- Track targeting, Tractor Aura and mining ranges.
- Persist changes via `StorageService` and reload on startup.
- Provide `reset()` to restore default values for all settings.

See [../../PLAN.md](../../PLAN.md) for polish goals.
