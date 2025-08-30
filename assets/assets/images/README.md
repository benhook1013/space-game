# images/

Sprites and background art.

- Store spritesheets, backgrounds and UI images here.
- A default `player.png` sprite is included. Add `enemy.png`, `asteroid.png`
  and `bullet.png` manually.
  Simple 32×32 placeholders can be generated with ImageMagick, for example:
  `convert -size 32x32 canvas:red enemy.png`.
- Reference assets through `assets.dart`; avoid hard-coded paths.
- List files in `assets_manifest.json` (see `../../assets_manifest.md`).
- See [../../ASSET_GUIDE.md](../../ASSET_GUIDE.md) for sourcing rules and
  credit assets in [../../ASSET_CREDITS.md](../../ASSET_CREDITS.md).
- See [../../PLAN.md](../../PLAN.md) for asset guidelines.
