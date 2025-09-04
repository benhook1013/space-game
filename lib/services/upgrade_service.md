# UpgradeService

Manages purchasing upgrades using collected minerals.

## Responsibilities

- Expose a list of available upgrades with ids, names and costs.
- Track which upgrades have been purchased.
- Deduct mineral costs via `ScoreService` when buying.
- Provide a `ValueListenable` of purchased upgrade ids for UI widgets.
- Future work: apply upgrade effects to gameplay systems.

See [../../PLAN.md](../../PLAN.md) for progression goals.
