import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/services/score_service.dart';
import 'package:space_game/services/settings_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/upgrade_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('High score persistence', () {
    test('StorageService persists and resets high score', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      expect(storage.getHighScore(), 0);
      expect(await storage.setHighScore(42), isTrue);
      expect(storage.getHighScore(), 42);
      expect(await storage.resetHighScore(), isTrue);
      expect(storage.getHighScore(), 0);
    });

    test('ScoreService updates high score and persists across sessions',
        () async {
      SharedPreferences.setMockInitialValues({});
      var storage = await StorageService.create();
      var score = ScoreService(storageService: storage);

      score.addScore(10);
      await score.updateHighScoreIfNeeded();
      score.dispose();

      storage = await StorageService.create();
      score = ScoreService(storageService: storage);
      expect(score.highScore.value, 10);

      expect(await score.resetHighScore(), isTrue);
      expect(score.highScore.value, 0);
      expect(storage.getHighScore(), 0);
    });

    test('High score and upgrades persist across sessions', () async {
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

      // Simulate a restart by recreating services with the same storage.
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

      // Another restart to ensure persistence across multiple sessions.
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
  });
}
