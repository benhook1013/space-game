# Starfield

Deterministic parallax starfield rendered by `StarfieldComponent`.

- Stars are generated per tile using Poisson-disk sampling seeded by the
  `(tileX, tileY)` coordinates so results are reproducible.
- Low-frequency Simplex noise modulates the minimum distance between stars to
  create subtle clusters and voids. A density multiplier on each layer allows
  the game to tune how busy the sky appears. Global density and brightness
  multipliers expose accessibility controls. A gamma value modulates brightness
  using a non-linear curve, enabling more nuanced contrast adjustments.
- Star generation runs in a background isolate (`compute`) so tile creation
  doesn't stall the main thread.
- Each layer owns a single `OpenSimplexNoise` instance reused for all tiles,
  reducing object churn during star generation.
- Multiple `StarfieldLayerConfig`s may be provided. Each layer renders with its
  own parallax factor, density and twinkle speed, enabling a simple depth
  effect. Tile size is configurable at runtime to scale quality versus
  performance.
- Stars are drawn via `Canvas.drawAtlas` using a pre-rendered star sprite, so
  each tile issues a single draw call even when many stars are visible.
- Individual stars store randomised twinkle amplitude and frequency for a more
  organic animation.
- Tiles are generated asynchronously and cached in an LRU map so camera movement
  never blocks the render loop. Cache size is bounded by each layer's
  `maxCacheTiles`.
- Star colours come from a selectable palette, allowing theme-driven visuals.
- A `debugDrawTiles` flag outlines each tile with a translucent stroke for
  development verification. `SpaceGame.toggleDebug` flips this on whenever the
  game's debug mode is enabled so tile borders appear alongside other debug
  visuals.
- Added to `SpaceGame` with a negative priority so it always renders beneath
  gameplay components.

## Future Enhancements

- Optional nebula or distant galaxy overlays may draw above the starfield to
  add ambience while leaving the deterministic tiles untouched. These overlays
  could use noise-generated sprites or a pre-rendered bitmap and expose
  toggles and density controls in the settings overlay.
