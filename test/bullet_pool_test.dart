import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/components.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/components/bullet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bullets are pooled only when released and reset on reuse', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    final bullet1 = game.pools.acquire<BulletComponent>(
      (b) => b.reset(Vector2.zero(), Vector2(0, -1)),
    );
    final bullet2 = game.pools.acquire<BulletComponent>(
      (b) => b.reset(Vector2.all(5), Vector2(0, -1)),
    );
    // A new instance should be created when the previous bullet hasn't been released.
    expect(identical(bullet1, bullet2), isFalse);

    // Once released, the same instance can be reused and reset to new values.
    game.pools.release(bullet1);
    final bullet3 = game.pools.acquire<BulletComponent>(
      (b) => b.reset(Vector2.all(10), Vector2(0, -1)),
    );
    expect(identical(bullet1, bullet3), isTrue);
    expect(bullet3.position, Vector2.all(10));
  });
}
