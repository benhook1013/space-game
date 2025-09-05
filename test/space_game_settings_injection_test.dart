import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/settings_service.dart';
import 'package:space_game/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SpaceGame attaches storage to provided SettingsService', () async {
    SharedPreferences.setMockInitialValues({'hudButtonScale': 0.8});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final settings = SettingsService();

    final game = SpaceGame(
      storageService: storage,
      audioService: audio,
      settingsService: settings,
    );

    expect(game.settingsService, same(settings));
    expect(settings.hudButtonScale.value, 0.8);

    settings.hudButtonScale.value = 1.3;
    await Future.delayed(Duration.zero);
    final reloaded = SettingsService(storage: storage);
    expect(reloaded.hudButtonScale.value, 1.3);
  });
}
