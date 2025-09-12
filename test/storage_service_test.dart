import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService', () {
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

    test('throws for unsupported types', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      expect(
        () => storage.getValue<DateTime>('now', DateTime.now()),
        throwsUnsupportedError,
      );
      expect(
        () => storage.setValue<DateTime>('now', DateTime.now()),
        throwsUnsupportedError,
      );
    });
  });
}
