# UpgradeService

Manages purchasing upgrades using collected minerals.

## Responsibilities

- Expose a list of available upgrades with ids, names and costs.
- Track which upgrades have been purchased.
- Persist purchased upgrades via `StorageService` so they survive app restarts.
- Deduct mineral costs via `ScoreService` when buying.
- Provide a `ValueListenable` of purchased upgrade ids for UI widgets.
- Provide derived values like bullet cooldown, mining pulse interval, targeting
  range, Tractor Aura radius, player speed and health regeneration based on
  purchased upgrades.

See [../../PLAN.md](../../PLAN.md) for progression goals.
