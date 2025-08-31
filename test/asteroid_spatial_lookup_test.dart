import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/components/asteroid.dart';
import 'package:space_game/game/event_bus.dart';

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('nearbyAsteroids returns asteroids within radius', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll(Assets.asteroids);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();

    final a1 = game.pools.acquire<AsteroidComponent>(
      (a) => a.reset(Vector2.zero(), Vector2.zero()),
    );
    final a2 = game.pools.acquire<AsteroidComponent>(
      (a) => a.reset(Vector2(100, 0), Vector2.zero()),
    );
    final a3 = game.pools.acquire<AsteroidComponent>(
      (a) => a.reset(Vector2(500, 500), Vector2.zero()),
    );
    await game.add(a1);
    await game.add(a2);
    await game.add(a3);
    game.update(0);
    game.update(0);
    game.eventBus.emit(ComponentSpawnEvent<AsteroidComponent>(a1));
    game.eventBus.emit(ComponentSpawnEvent<AsteroidComponent>(a2));
    game.eventBus.emit(ComponentSpawnEvent<AsteroidComponent>(a3));

    final nearby = game.pools.nearbyAsteroids(Vector2.zero(), 150).toList();
    expect(nearby.contains(a1), isTrue);
    expect(nearby.contains(a2), isTrue);
    expect(nearby.contains(a3), isFalse);
  });
}
