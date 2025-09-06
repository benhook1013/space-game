import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService', () {
    test('persists and retrieves high score', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      expect(storage.getHighScore(), 0);
      await storage.setHighScore(42);
      expect(storage.getHighScore(), 42);
    });

    test('resetHighScore clears value', () async {
      SharedPreferences.setMockInitialValues({'highScore': 99});
      final storage = await StorageService.create();
      expect(storage.getHighScore(), 99);
      await storage.resetHighScore();
      expect(storage.getHighScore(), 0);
    });

    test('persists selected player sprite index', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      expect(storage.getPlayerSpriteIndex(), 0);
      await storage.setPlayerSpriteIndex(1);
      expect(storage.getPlayerSpriteIndex(), 1);
    });
  });
}
