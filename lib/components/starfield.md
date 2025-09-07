
# Starfield

Deterministic world-space starfield drawn with `CustomPainter`.

- Stars are generated per chunk using Poisson-disk sampling seeded by the
  `(chunkX, chunkY)` coordinates so results are reproducible.
- A weighted radius/brightness distribution (≈80% tiny, 19% small, 1% medium)
  gives variation; an optional subtle blue/yellow colour jitter adds depth.
- Low-frequency Simplex noise modulates spawn probability for soft clusters and
  voids.
- Star data is cached per chunk. When rendering, the painter translates by
  `-playerPosition` and draws circles via `canvas.drawCircle`, iterating from
  faint to bright for gentle blending.
- If rendering cost spikes, cache layers with `PictureRecorder` or
  `Canvas.saveLayer`.
- Added to `SpaceGame` with a negative priority so it always renders beneath
  gameplay components.
