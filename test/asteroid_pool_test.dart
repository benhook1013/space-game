import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/components.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('asteroid instances are reused from pool', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    final asteroid1 = game.acquireAsteroid(Vector2.zero(), Vector2.zero());
    game.releaseAsteroid(asteroid1);
    final asteroid2 = game.acquireAsteroid(Vector2.zero(), Vector2.zero());
    expect(identical(asteroid1, asteroid2), isTrue);
  });
}
