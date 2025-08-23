import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/audio_service.dart';

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
  });

  group('AudioService', () {
    test('toggleMute updates storage', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      final audio = await AudioService.create(storage);
      expect(audio.muted.value, isFalse);
      await audio.toggleMute();
      expect(audio.muted.value, isTrue);
      expect(storage.isMuted(), isTrue);
    });
  });
}
