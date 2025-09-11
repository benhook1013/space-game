import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/components/asteroid.dart';
import 'package:space_game/components/bullet.dart';
import 'package:space_game/game/event_bus.dart';
import 'package:space_game/game/pool_manager.dart';
import 'package:space_game/assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PoolManager', () {
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
  });
}
