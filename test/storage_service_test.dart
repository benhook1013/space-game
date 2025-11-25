import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StorageService', () {
    test('supports typed getters/setters for primitives and selection',
        () async {
      final storage = await StorageService.create();
      expect(storage.getPlayerSpriteIndex(), 0);
      expect(await storage.setPlayerSpriteIndex(1), isTrue);
      expect(storage.getPlayerSpriteIndex(), 1);

      expect(await storage.setValue<String>('greeting', 'hello'), isTrue);
      expect(storage.getValue<String>('greeting', ''), 'hello');

      expect(await storage.setString('name', 'Alice'), isTrue);
      expect(storage.getString('name', ''), 'Alice');

      expect(await storage.setValue<double>('volume', 0.5), isTrue);
      expect(storage.getValue<double>('volume', 0), 0.5);

      expect(await storage.setValue<bool>('muted', true), isTrue);
      expect(storage.getValue<bool>('muted', false), isTrue);
    });

    test('persists values across instances', () async {
      var storage = await StorageService.create();
      await storage.setStringList('upgrades', ['speed1', 'fireRate1']);
      await storage.setPlayerSpriteIndex(2);

      storage = await StorageService.create();
      expect(storage.getPlayerSpriteIndex(), 2);
      expect(storage.getStringList('upgrades', []), ['speed1', 'fireRate1']);
    });

    test('throws for unsupported types', () async {
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
