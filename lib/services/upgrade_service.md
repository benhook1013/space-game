# UpgradeService

Manages purchasing upgrades using collected minerals.

## Responsibilities

- Expose a list of available upgrades with ids, names and costs.
- Track which upgrades have been purchased.
- Deduct mineral costs via `ScoreService` when buying.
- Provide a `ValueListenable` of purchased upgrade ids for UI widgets.
- Provide derived values like bullet cooldown and mining pulse interval based
  on purchased upgrades.

See [../../PLAN.md](../../PLAN.md) for progression goals.
