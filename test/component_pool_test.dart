import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/assets.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/components/asteroid.dart';
import 'package:space_game/components/enemy.dart';
import 'package:space_game/components/bullet.dart';
import 'package:space_game/enemy_faction.dart';

Future<SpaceGame> _createGame() async {
  SharedPreferences.setMockInitialValues({});
  final storage = await StorageService.create();
  final audio = await AudioService.create(storage);
  return SpaceGame(storageService: storage, audioService: audio);
}

class PoolTestCase<T extends Component> {
  PoolTestCase({
    required this.loadAssets,
    required this.acquire,
    required this.acquireAfterRelease,
    this.acquireWithoutRelease,
    this.verifyAfterReuse,
  });

  final Future<void> Function() loadAssets;
  final T Function(SpaceGame game) acquire;
  final T Function(SpaceGame game) acquireAfterRelease;
  final T Function(SpaceGame game)? acquireWithoutRelease;
  final void Function(T component)? verifyAfterReuse;
}

Future<void> _runPoolCase<T extends Component>(PoolTestCase<T> c) async {
  await c.loadAssets();
  final game = await _createGame();

  final first = c.acquire(game);

  if (c.acquireWithoutRelease != null) {
    final second = c.acquireWithoutRelease!(game);
    expect(identical(first, second), isFalse);
  }

  game.pools.release(first);

  final reused = c.acquireAfterRelease(game);
  expect(identical(first, reused), isTrue);

  c.verifyAfterReuse?.call(reused);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('component pooling', () {
    test('AsteroidComponent instances are reused after release', () async {
      final c = PoolTestCase<AsteroidComponent>(
        loadAssets: () => Flame.images.loadAll(Assets.asteroids),
        acquire: (game) => game.pools.acquire<AsteroidComponent>(
          (a) => a.reset(Vector2.zero(), Vector2.zero()),
        ),
        acquireAfterRelease: (game) => game.pools.acquire<AsteroidComponent>(
          (a) => a.reset(Vector2.zero(), Vector2.zero()),
        ),
      );
      await _runPoolCase<AsteroidComponent>(c);
    });

    test('EnemyComponent instances are reused after release', () async {
      final c = PoolTestCase<EnemyComponent>(
        loadAssets: () => Flame.images.loadAll(Assets.enemies),
        acquire: (game) => game.pools.acquire<EnemyComponent>(
          (e) => e.reset(Vector2.zero(), EnemyFaction.faction1),
        ),
        acquireAfterRelease: (game) => game.pools.acquire<EnemyComponent>(
          (e) => e.reset(Vector2.zero(), EnemyFaction.faction1),
        ),
      );
      await _runPoolCase<EnemyComponent>(c);
    });

    test('BulletComponent requires release before reuse', () async {
      final c = PoolTestCase<BulletComponent>(
        loadAssets: () async {},
        acquire: (game) => game.pools.acquire<BulletComponent>(
          (b) => b.reset(Vector2.zero(), Vector2(0, -1)),
        ),
        acquireWithoutRelease: (game) => game.pools.acquire<BulletComponent>(
          (b) => b.reset(Vector2.all(5), Vector2(0, -1)),
        ),
        acquireAfterRelease: (game) => game.pools.acquire<BulletComponent>(
          (b) => b.reset(Vector2.all(10), Vector2(0, -1)),
        ),
        verifyAfterReuse: (b) => expect(b.position, Vector2.all(10)),
      );
      await _runPoolCase<BulletComponent>(c);
    });
  });
}
