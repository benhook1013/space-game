import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/components.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bullet instances are reused from pool', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    final bullet1 = game.pools.acquireBullet(Vector2.zero(), Vector2(0, -1));
    game.pools.releaseBullet(bullet1);
    final bullet2 = game.pools.acquireBullet(Vector2.zero(), Vector2(0, -1));
    expect(identical(bullet1, bullet2), isTrue);
  });
}
