import 'package:flame/components.dart';

import '../components/asteroid.dart';
import '../components/bullet.dart';
import '../components/enemy.dart';
import '../components/mineral.dart';
import '../constants.dart';
import '../util/object_pool.dart';
import '../util/spatial_grid.dart';
import 'event_bus.dart';

/// Manages pooled game components to reduce allocations.
class PoolManager {
  PoolManager({required GameEventBus events}) : _events = events {
    _register<BulletComponent>(() => BulletComponent());
    _register<EnemyComponent>(() => EnemyComponent());
    _register<MineralComponent>(() => MineralComponent());
    _register<AsteroidComponent>(
      () => AsteroidComponent(),
      onSpawn: _asteroidGrid.add,
      onRemove: _asteroidGrid.remove,
    );
  }

  final GameEventBus _events;

  final Map<Type, ObjectPool<dynamic>> _pools = {};
  final Map<Type, List<dynamic>> _active = {};
  final Map<Type, void Function(dynamic)> _onRemove = {};
  final Map<Type, void Function(dynamic)> _onSpawn = {};

  final SpatialGrid<AsteroidComponent> _asteroidGrid =
      SpatialGrid(cellSize: Constants.spatialGridCellSize);

  void _register<T extends Component>(
    T Function() factory, {
    void Function(T)? onSpawn,
    void Function(T)? onRemove,
  }) {
    _pools[T] = ObjectPool<T>(factory);
    _active[T] = <T>[];
    if (onSpawn != null) {
      _onSpawn[T] = (dynamic c) => onSpawn(c as T);
    }
    if (onRemove != null) {
      _onRemove[T] = (dynamic c) => onRemove(c as T);
    }

    _events.on<ComponentRemoveEvent<T>>().listen((event) {
      (_active[T] as List<T>).remove(event.component);
      _onRemove[T]?.call(event.component);
      release(event.component);
    });
  }

  /// Retrieves an instance of [T] from its pool.
  T acquire<T extends Component>(void Function(T) reset) {
    final pool = _pools[T] as ObjectPool<T>;
    final obj = pool.acquire(reset);
    final active = _active[T] as List<T>;
    if (!active.contains(obj)) {
      active.add(obj);
      _onSpawn[T]?.call(obj);
    }
    return obj;
  }

  /// Returns [component] to its pool for reuse.
  void release<T extends Component>(T component) {
    final active = _active[T] as List<T>?;
    active?.remove(component);
    _onRemove[T]?.call(component);
    final pool = _pools[T] as ObjectPool<T>?;
    pool?.release(component);
  }

  /// Returns the active components for type [T].
  List<T> components<T extends Component>() => _active[T] as List<T>? ?? <T>[];

  /// Updates the debug flag on all pooled and active components.
  ///
  /// Components can have children that also render debug information. Ensure
  /// the flag is applied recursively so pooled objects don't retain stale
  /// debug state between spawns.
  void applyDebugMode(bool enabled) {
    for (final list in _active.values) {
      for (final component in list.cast<Component>()) {
        _applyDebugRecursively(component, enabled);
      }
    }
    for (final pool in _pools.values) {
      for (final obj in pool.items) {
        if (obj is Component) {
          _applyDebugRecursively(obj, enabled);
        }
      }
    }
  }

  void _applyDebugRecursively(Component component, bool enabled) {
    component.debugMode = enabled;
    for (final child in component.children) {
      _applyDebugRecursively(child, enabled);
    }
  }

  void updateAsteroidPosition(
    AsteroidComponent asteroid,
    Vector2 previousPosition,
  ) {
    _asteroidGrid.update(asteroid, previousPosition);
  }

  Iterable<AsteroidComponent> nearbyAsteroids(
    Vector2 position,
    double radius,
  ) =>
      _asteroidGrid.query(position, radius);

  /// Removes all active components and resets tracking structures.
  void clear() {
    for (final list in _active.values) {
      for (final component in List<Component>.from(list as List<Component>)) {
        component.removeFromParent();
      }
      list.clear();
    }
    _asteroidGrid.clear();
  }
}
