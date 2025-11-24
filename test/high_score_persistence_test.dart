import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/services/score_service.dart';
import 'package:space_game/services/settings_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/upgrade_service.dart';

class _FailingStorageService extends StorageService {
  _FailingStorageService(super.prefs);

  @override
  Future<bool> setHighScore(int value) async => false;

  @override
  Future<bool> resetHighScore() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('High score persistence', () {
    test('ScoreService updates high score and persists across sessions',
        () async {
      SharedPreferences.setMockInitialValues({});
      var storage = await StorageService.create();
      var score = ScoreService(storageService: storage);

      expect(storage.getHighScore(), 0);

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

    test('ScoreService retains high score when storage write fails', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = _FailingStorageService(prefs);
      final score = ScoreService(storageService: storage);

      score.addScore(10);
      await score.updateHighScoreIfNeeded();
      expect(score.highScore.value, 0);
    });

    test('ScoreService retains high score when reset fails', () async {
      SharedPreferences.setMockInitialValues({'highScore': 42});
      final prefs = await SharedPreferences.getInstance();
      final storage = _FailingStorageService(prefs);
      final score = ScoreService(storageService: storage);

      expect(score.highScore.value, 42);
      expect(await score.resetHighScore(), isFalse);
      expect(score.highScore.value, 42);
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

      const scoreValue = 100;
      score.addScore(scoreValue);
      await score.updateHighScoreIfNeeded();
      final upgrade = upgradeService.upgrades.first;
      score.addMinerals(upgrade.cost);
      upgradeService.buy(upgrade);

      score.reset();
      expect(score.score.value, 0);
      expect(score.highScore.value, scoreValue);
      expect(upgradeService.isPurchased(upgrade.id), isTrue);

      // Simulate a restart by recreating services with the same storage.
      storage = await StorageService.create();
      score = ScoreService(storageService: storage);
      settings = SettingsService();
      upgradeService = UpgradeService(
        scoreService: score,
        storageService: storage,
        settingsService: settings,
      );

      expect(score.score.value, 0);
      expect(score.highScore.value, scoreValue);
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

      expect(score.score.value, 0);
      expect(score.highScore.value, scoreValue);
      expect(upgradeService.isPurchased(upgrade.id), isTrue);
    });
  });
}
