# Starfield

Deterministic world-space starfield rendered by `StarfieldComponent`.

- Stars are generated per chunk using Poisson-disk sampling seeded by the
  `(chunkX, chunkY)` coordinates so results are reproducible.
- Low-frequency Simplex noise modulates the minimum distance between stars to
  create subtle clusters and voids.
- A weighted radius/brightness spread (≈80% tiny, 19% small, 1% medium) adds
  variation, with optional subtle blue/yellow colour jitter.
- Each chunk pre-renders its stars into a cached `Picture`. Tiles outside a
  small margin around the camera are discarded to keep memory use bounded.
  During `render` the canvas translates by `-cameraOrigin` so the player flies
  over a static backdrop. Stars within each tile sort by radius so faint stars
  render first for smoother blending.
- A `debugDrawTiles` flag outlines each tile with a translucent stroke for
  development verification.
- Added to `SpaceGame` with a negative priority so it always renders beneath
  gameplay components.
