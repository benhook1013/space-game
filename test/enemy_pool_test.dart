import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:flame/components.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('enemy instances are reused from pool', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    final enemy1 = game.acquireEnemy(Vector2.zero());
    game.releaseEnemy(enemy1);
    final enemy2 = game.acquireEnemy(Vector2.zero());
    expect(identical(enemy1, enemy2), isTrue);
  });
}
