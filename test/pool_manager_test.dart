import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/asteroid.dart';
import 'package:space_game/components/bullet.dart';
import 'package:space_game/components/enemy.dart';
import 'package:space_game/enemy_faction.dart';
import 'package:space_game/game/event_bus.dart';
import 'package:space_game/game/pool_manager.dart';
import 'package:space_game/util/object_pool.dart';

class _ComponentPoolCase<T extends Component> {
  _ComponentPoolCase({
    required this.description,
    required this.acquire,
    required this.acquireAfterRelease,
    this.loadAssets,
    this.acquireWithoutRelease,
    this.verifyAfterReuse,
  });

  final String description;
  final Future<void> Function()? loadAssets;
  final T Function(PoolManager pools) acquire;
  final T Function(PoolManager pools) acquireAfterRelease;
  final T Function(PoolManager pools)? acquireWithoutRelease;
  final void Function(T component)? verifyAfterReuse;
}

Future<void> _runComponentPoolCase<T extends Component>(
  _ComponentPoolCase<T> c,
) async {
  await c.loadAssets?.call();
  final pools = PoolManager(events: GameEventBus());

  final first = c.acquire(pools);

  if (c.acquireWithoutRelease != null) {
    final second = c.acquireWithoutRelease!(pools);
    expect(identical(first, second), isFalse);
  }

  pools.release<T>(first);

  final reused = c.acquireAfterRelease(pools);
  expect(identical(first, reused), isTrue);

  c.verifyAfterReuse?.call(reused);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PoolManager', () {
    test('ObjectPool invokes discard callback for full pools and clearing', () {
      final discarded = <int>[];
      final pool = ObjectPool<int>(
        () => 0,
        maxSize: 1,
        onDiscard: discarded.add,
      );

      pool.release(1);
      pool.release(2); // Discarded because the pool is full.
      pool.clear(); // Discards the cached instance.

      expect(discarded, [2, 1]);
      expect(pool.items, isEmpty);
    });

    test('acquire, release via event and clear lifecycle', () {
      final events = GameEventBus();
      final pools = PoolManager(events: events);

      final bullet = pools.acquire<BulletComponent>(
          (b) => b.reset(Vector2.zero(), Vector2.zero()));
      expect(pools.components<BulletComponent>(), contains(bullet));

      events.emit(ComponentRemoveEvent<BulletComponent>(bullet));
      expect(pools.components<BulletComponent>(), isEmpty);

      final reused = pools.acquire<BulletComponent>(
          (b) => b.reset(Vector2.zero(), Vector2.zero()));
      expect(identical(reused, bullet), isTrue);

      pools.clear();
      expect(pools.components<BulletComponent>(), isEmpty);
    });

    test('asteroid grid queries and updates', () async {
      final events = GameEventBus();
      final pools = PoolManager(events: events);
      await Flame.images.loadAll(Assets.asteroids);

      final asteroid = pools.acquire<AsteroidComponent>(
          (a) => a.reset(Vector2.zero(), Vector2.zero()));
      expect(pools.nearbyAsteroids(Vector2.zero(), 100), contains(asteroid));

      final previous = asteroid.position.clone();
      asteroid.position = Vector2(400, 0);
      pools.updateAsteroidPosition(asteroid, previous);

      expect(pools.nearbyAsteroids(Vector2.zero(), 100), isEmpty);
      expect(pools.nearbyAsteroids(Vector2(400, 0), 100), contains(asteroid));

      pools.release(asteroid);
      expect(pools.nearbyAsteroids(Vector2(400, 0), 100), isEmpty);

      final second = pools.acquire<AsteroidComponent>(
          (a) => a.reset(Vector2.zero(), Vector2.zero()));
      expect(pools.nearbyAsteroids(Vector2.zero(), 100), contains(second));
      pools.clear();
      expect(pools.nearbyAsteroids(Vector2.zero(), 100), isEmpty);
    });

    test('applyDebugMode propagates to pooled components', () async {
      final events = GameEventBus();
      final pools = PoolManager(events: events);
      await Flame.images.load(Assets.bullet);

      final bullet = pools.acquire<BulletComponent>(
          (b) => b.reset(Vector2.zero(), Vector2.zero()));
      final child = Component();
      await bullet.add(child);
      bullet.updateTree(0);

      pools.release(bullet);
      expect(bullet.debugMode, isFalse);
      expect(child.debugMode, isFalse);

      pools.applyDebugMode(true);
      expect(bullet.debugMode, isTrue);
      expect(child.debugMode, isTrue);

      final reused = pools.acquire<BulletComponent>(
          (b) => b.reset(Vector2.zero(), Vector2.zero()));
      expect(identical(reused, bullet), isTrue);
      expect(reused.debugMode, isTrue);
      expect(child.debugMode, isTrue);

      pools.applyDebugMode(false);
      expect(reused.debugMode, isFalse);
      expect(child.debugMode, isFalse);
    });

    group('component pooling reuse', () {
      test(
        'AsteroidComponent instances are reused',
        () => _runComponentPoolCase<AsteroidComponent>(
          _ComponentPoolCase<AsteroidComponent>(
            description: 'AsteroidComponent instances are reused',
            loadAssets: () => Flame.images.loadAll(Assets.asteroids),
            acquire: (pools) => pools.acquire<AsteroidComponent>(
                (a) => a.reset(Vector2.zero(), Vector2.zero())),
            acquireAfterRelease: (pools) => pools.acquire<AsteroidComponent>(
                (a) => a.reset(Vector2.zero(), Vector2.zero())),
          ),
        ),
      );

      test(
        'EnemyComponent instances are reused',
        () => _runComponentPoolCase<EnemyComponent>(
          _ComponentPoolCase<EnemyComponent>(
            description: 'EnemyComponent instances are reused',
            loadAssets: () => Flame.images.loadAll(Assets.enemies),
            acquire: (pools) => pools.acquire<EnemyComponent>(
                (e) => e.reset(Vector2.zero(), EnemyFaction.faction1)),
            acquireAfterRelease: (pools) => pools.acquire<EnemyComponent>(
                (e) => e.reset(Vector2.zero(), EnemyFaction.faction1)),
          ),
        ),
      );

      test(
        'BulletComponent requires release before reuse',
        () => _runComponentPoolCase<BulletComponent>(
          _ComponentPoolCase<BulletComponent>(
            description: 'BulletComponent requires release before reuse',
            acquire: (pools) => pools.acquire<BulletComponent>(
                (b) => b.reset(Vector2.zero(), Vector2(0, -1))),
            acquireWithoutRelease: (pools) => pools.acquire<BulletComponent>(
                (b) => b.reset(Vector2.all(5), Vector2(0, -1))),
            acquireAfterRelease: (pools) => pools.acquire<BulletComponent>(
                (b) => b.reset(Vector2.all(10), Vector2(0, -1))),
            verifyAfterReuse: (b) => expect(b.position, Vector2.all(10)),
          ),
        ),
      );
    });
  });
}
