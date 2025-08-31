import 'package:flame/components.dart';

import '../components/asteroid.dart';
import '../components/bullet.dart';
import '../components/enemy.dart';
import '../components/mineral.dart';
import '../constants.dart';
import '../util/object_pool.dart';
import '../util/spatial_grid.dart';
import 'event_bus.dart';
import 'space_game.dart';

/// Manages pooled game components to reduce allocations.
class PoolManager {
  PoolManager({required SpaceGame game, required GameEventBus events})
      : _game = game,
        _events = events {
    _events.on<ComponentSpawnEvent<EnemyComponent>>().listen((event) {
      enemies.add(event.component);
    });
    _events.on<ComponentRemoveEvent<EnemyComponent>>().listen((event) {
      enemies.remove(event.component);
      releaseEnemy(event.component);
    });
    _events.on<ComponentSpawnEvent<AsteroidComponent>>().listen((event) {
      asteroids.add(event.component);
      _asteroidGrid.add(event.component);
    });
    _events.on<ComponentRemoveEvent<AsteroidComponent>>().listen((event) {
      asteroids.remove(event.component);
      _asteroidGrid.remove(event.component);
      releaseAsteroid(event.component);
    });
    _events.on<ComponentSpawnEvent<MineralComponent>>().listen((event) {
      mineralPickups.add(event.component);
    });
    _events.on<ComponentRemoveEvent<MineralComponent>>().listen((event) {
      mineralPickups.remove(event.component);
      releaseMineral(event.component);
    });
    _events.on<ComponentSpawnEvent<BulletComponent>>().listen((event) {
      bullets.add(event.component);
    });
    _events.on<ComponentRemoveEvent<BulletComponent>>().listen((event) {
      bullets.remove(event.component);
      releaseBullet(event.component);
    });
  }

  final SpaceGame _game;
  final GameEventBus _events;

  final ObjectPool<BulletComponent> _bulletPool =
      ObjectPool(() => BulletComponent());
  final ObjectPool<AsteroidComponent> _asteroidPool =
      ObjectPool(() => AsteroidComponent());
  final ObjectPool<EnemyComponent> _enemyPool =
      ObjectPool(() => EnemyComponent());
  final ObjectPool<MineralComponent> _mineralPool =
      ObjectPool(() => MineralComponent());

  /// Active bullets tracked for cleanup.
  final List<BulletComponent> bullets = [];

  /// Active enemies tracked for quick lookup.
  final List<EnemyComponent> enemies = [];

  /// Active asteroids tracked for quick lookup.
  final List<AsteroidComponent> asteroids = [];

  final SpatialGrid<AsteroidComponent> _asteroidGrid =
      SpatialGrid(cellSize: Constants.spatialGridCellSize);

  /// Active mineral pickups tracked for cleanup.
  final List<MineralComponent> mineralPickups = [];

  /// Retrieves a bullet from the pool or creates a new one.
  BulletComponent acquireBullet(Vector2 position, Vector2 direction) =>
      _bulletPool.acquire((bullet) => bullet.reset(position, direction));

  /// Returns [bullet] to the pool for reuse.
  void releaseBullet(BulletComponent bullet) => _bulletPool.release(bullet);

  /// Retrieves an asteroid from the pool or creates a new one.
  AsteroidComponent acquireAsteroid(Vector2 position, Vector2 velocity) =>
      _asteroidPool.acquire((asteroid) => asteroid.reset(position, velocity));

  /// Returns [asteroid] to the pool for reuse.
  void releaseAsteroid(AsteroidComponent asteroid) =>
      _asteroidPool.release(asteroid);

  /// Retrieves an enemy from the pool or creates a new one.
  EnemyComponent acquireEnemy(Vector2 position) =>
      _enemyPool.acquire((enemy) => enemy.reset(position));

  /// Returns [enemy] to the pool for reuse.
  void releaseEnemy(EnemyComponent enemy) => _enemyPool.release(enemy);

  /// Retrieves a mineral from the pool or creates a new one.
  MineralComponent acquireMineral(Vector2 position) =>
      _mineralPool.acquire((mineral) => mineral.reset(position));

  /// Returns [mineral] to the pool for reuse.
  void releaseMineral(MineralComponent mineral) =>
      _mineralPool.release(mineral);

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
    for (final enemy in enemies.toList()) {
      enemy.removeFromParent();
    }
    for (final asteroid in asteroids.toList()) {
      asteroid.removeFromParent();
    }
    for (final mineral in mineralPickups.toList()) {
      mineral.removeFromParent();
    }
    for (final bullet in bullets.toList()) {
      bullet.removeFromParent();
    }
    enemies.clear();
    asteroids.clear();
    mineralPickups.clear();
    bullets.clear();
    _asteroidGrid.clear();
  }
}
