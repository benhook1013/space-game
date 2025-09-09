# event_bus.dart

Lightweight synchronous event hub used by core game systems.

- All events extend the `GameEvent` base class.
- `GameEventBus` exposes `emit` and typed `on<T>()` helpers for broadcasting
  events using per-type streams to avoid runtime filtering.
- Components mix in `SpawnRemoveEmitter` so `ComponentSpawnEvent` and
  `ComponentRemoveEvent` fire when they are added or removed.
- `SpaceGame` creates a single bus instance and passes it to services like
  `TargetingService` and `PoolManager` for decoupled communication.
