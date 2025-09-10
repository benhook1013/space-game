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
      expect(await storage.setHighScore(42), isTrue);
      expect(storage.getHighScore(), 42);
    });

    test('resetHighScore clears value', () async {
      SharedPreferences.setMockInitialValues({'highScore': 99});
      final storage = await StorageService.create();
      expect(storage.getHighScore(), 99);
      expect(await storage.resetHighScore(), isTrue);
      expect(storage.getHighScore(), 0);
    });

    test('persists selected player sprite index', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      expect(storage.getPlayerSpriteIndex(), 0);
      expect(await storage.setPlayerSpriteIndex(1), isTrue);
      expect(storage.getPlayerSpriteIndex(), 1);
    });

    test('generic get/set handles strings', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      expect(await storage.setValue<String>('greeting', 'hello'), isTrue);
      expect(storage.getValue<String>('greeting', ''), 'hello');
    });

    test('string helpers persist values', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      expect(await storage.setString('name', 'Alice'), isTrue);
      expect(storage.getString('name', ''), 'Alice');
    });

    test('generic get/set handles double and bool', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      expect(await storage.setValue<double>('volume', 0.5), isTrue);
      expect(storage.getValue<double>('volume', 0), 0.5);
      expect(await storage.setValue<bool>('muted', true), isTrue);
      expect(storage.getValue<bool>('muted', false), isTrue);
    });

    test('high score persists across instances', () async {
      SharedPreferences.setMockInitialValues({});
      var storage = await StorageService.create();
      await storage.setHighScore(77);

      storage = await StorageService.create();
      expect(storage.getHighScore(), 77);
    });

    test('string list persists across instances', () async {
      SharedPreferences.setMockInitialValues({});
      var storage = await StorageService.create();
      await storage.setStringList('upgrades', ['speed1', 'fireRate1']);

      storage = await StorageService.create();
      expect(
        storage.getStringList('upgrades', []),
        ['speed1', 'fireRate1'],
      );
    });
  });
}
