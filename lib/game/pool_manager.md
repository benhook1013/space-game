# pool_manager.dart

Central registry for reusable component pools and spatial queries.

- Maintains pools for bullets, enemies, minerals and asteroids to minimise
  allocations.
- Listens to `ComponentRemoveEvent` on the `GameEventBus` to return objects to
  their pools and invoke any cleanup hooks.
- Tracks active asteroids in a small `SpatialGrid` so nearby rocks can be
  queried efficiently.
- Applies debug mode to all pooled objects when the game's debug flag changes.
