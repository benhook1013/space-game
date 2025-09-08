# Starfield

Deterministic parallax starfield rendered by `StarfieldComponent`.

- Stars are generated per tile using Poisson-disk sampling seeded by the
  `(tileX, tileY)` coordinates so results are reproducible.
- Low-frequency Simplex noise modulates the minimum distance between stars to
  create subtle clusters and voids. A density multiplier on each layer allows
  the game to tune how busy the sky appears.
- Multiple `StarfieldLayerConfig`s may be provided. Each layer renders with its
  own parallax factor, density and twinkle speed, enabling a simple depth
  effect.
- Tiles are generated asynchronously and cached in an LRU map so camera movement
  never blocks the render loop. Cache size is bounded by each layer's
  `maxCacheTiles`.
- Stars share a `Paint` instance and their colours are picked from a broader
  palette (white, blue, yellow and red). Their alpha is animated over time for a
  subtle twinkling.
- A `debugDrawTiles` flag outlines each tile with a translucent stroke for
  development verification. `SpaceGame.toggleDebug` flips this on whenever the
  game's debug mode is enabled so tile borders appear alongside other debug
  visuals.
- Added to `SpaceGame` with a negative priority so it always renders beneath
  gameplay components.
