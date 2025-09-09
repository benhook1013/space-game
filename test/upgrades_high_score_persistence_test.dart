import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/services/score_service.dart';
import 'package:space_game/services/settings_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/upgrade_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('high score and upgrades persist across sessions', () async {
    SharedPreferences.setMockInitialValues({});

    var storage = await StorageService.create();
    var score = ScoreService(storageService: storage);
    var settings = SettingsService();
    var upgradeService = UpgradeService(
      scoreService: score,
      storageService: storage,
      settingsService: settings,
    );

    score.addScore(100);
    await score.updateHighScoreIfNeeded();
    final upgrade = upgradeService.upgrades.first;
    score.addMinerals(upgrade.cost);
    upgradeService.buy(upgrade);

    // Simulate a restart by recreating services with the same underlying storage.
    storage = await StorageService.create();
    score = ScoreService(storageService: storage);
    settings = SettingsService();
    upgradeService = UpgradeService(
      scoreService: score,
      storageService: storage,
      settingsService: settings,
    );

    expect(score.highScore.value, 100);
    expect(upgradeService.isPurchased(upgrade.id), isTrue);
  });
}
