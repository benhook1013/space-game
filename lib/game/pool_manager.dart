import 'package:flame/components.dart';

import '../components/asteroid.dart';
import '../components/bullet.dart';
import '../components/enemy.dart';
import '../components/mineral.dart';
import '../constants.dart';
import '../util/spatial_grid.dart';

/// Manages pooled game components to reduce allocations.
class PoolManager {
  /// Pool of reusable bullets.
  final List<BulletComponent> _bulletPool = [];

  /// Pool of reusable asteroids.
  final List<AsteroidComponent> _asteroidPool = [];

  /// Pool of reusable enemies.
  final List<EnemyComponent> _enemyPool = [];

  /// Pool of reusable mineral pickups.
  final List<MineralComponent> _mineralPool = [];

  /// Active enemies tracked for quick lookup.
  final List<EnemyComponent> enemies = [];

  /// Active asteroids tracked for quick lookup.
  final List<AsteroidComponent> asteroids = [];

  final SpatialGrid<AsteroidComponent> _asteroidGrid =
      SpatialGrid(cellSize: Constants.spatialGridCellSize);

  /// Active mineral pickups tracked for cleanup.
  final List<MineralComponent> mineralPickups = [];

  /// Retrieves a bullet from the pool or creates a new one.
  BulletComponent acquireBullet(Vector2 position, Vector2 direction) {
    final bullet =
        _bulletPool.isNotEmpty ? _bulletPool.removeLast() : BulletComponent();
    bullet.reset(position, direction);
    return bullet;
  }

  /// Returns [bullet] to the pool for reuse.
  void releaseBullet(BulletComponent bullet) {
    _bulletPool.add(bullet);
  }

  /// Retrieves an asteroid from the pool or creates a new one.
  AsteroidComponent acquireAsteroid(Vector2 position, Vector2 velocity) {
    final asteroid = _asteroidPool.isNotEmpty
        ? _asteroidPool.removeLast()
        : AsteroidComponent();
    asteroid.reset(position, velocity);
    return asteroid;
  }

  /// Returns [asteroid] to the pool for reuse.
  void releaseAsteroid(AsteroidComponent asteroid) {
    _asteroidPool.add(asteroid);
  }

  void trackAsteroid(AsteroidComponent asteroid) {
    asteroids.add(asteroid);
    _asteroidGrid.add(asteroid);
  }

  void untrackAsteroid(AsteroidComponent asteroid) {
    asteroids.remove(asteroid);
    _asteroidGrid.remove(asteroid);
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

  /// Retrieves an enemy from the pool or creates a new one.
  EnemyComponent acquireEnemy(Vector2 position) {
    final enemy =
        _enemyPool.isNotEmpty ? _enemyPool.removeLast() : EnemyComponent();
    enemy.reset(position);
    return enemy;
  }

  /// Returns [enemy] to the pool for reuse.
  void releaseEnemy(EnemyComponent enemy) {
    _enemyPool.add(enemy);
  }

  /// Retrieves a mineral from the pool or creates a new one.
  MineralComponent acquireMineral(Vector2 position) {
    final mineral = _mineralPool.isNotEmpty
        ? _mineralPool.removeLast()
        : MineralComponent();
    mineral.reset(position);
    return mineral;
  }

  /// Returns [mineral] to the pool for reuse.
  void releaseMineral(MineralComponent mineral) {
    _mineralPool.add(mineral);
  }
}
