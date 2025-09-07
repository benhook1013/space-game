
# Starfield

Deterministic world-space starfield drawn with `CustomPainter`.

- Stars are generated per world-space chunk using Poisson-disk sampling seeded by chunk coordinates.
- Low-frequency Simplex noise modulates spawn density to create clusters and voids.
- Star radius and brightness follow a weighted distribution; subtle colour jitter adds variation.
- Generated stars are cached per chunk and rendered as tiny circles so the player moves over a static field.
- Added to `SpaceGame` with a negative priority so it always renders beneath gameplay components.
