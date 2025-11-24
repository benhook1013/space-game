import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/constants.dart';
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

Future<StorageService> _createStorage({Map<String, Object>? initialValues}) async {
  if (initialValues != null) {
    SharedPreferences.setMockInitialValues(initialValues);
  }
  return StorageService.create();
}

Future<_FailingStorageService> _createFailingStorage(
  Map<String, Object> initialValues,
) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final prefs = await SharedPreferences.getInstance();
  return _FailingStorageService(prefs);
}

ScoreService _createScore(StorageService storage) =>
    ScoreService(storageService: storage);

UpgradeService _createUpgradeService(
  ScoreService score,
  StorageService storage,
) {
  return UpgradeService(
    scoreService: score,
    storageService: storage,
    settingsService: SettingsService(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('High score persistence', () {
    test('ScoreService reset restores health and persists progress across restart',
        () async {
      final storage = await _createStorage(initialValues: {});
      final score = _createScore(storage);
      final upgradeService = _createUpgradeService(score, storage);

      const scoreValue = 100;
      final upgrade = upgradeService.upgrades.first;

      expect(storage.getHighScore(), 0);

      score.addScore(scoreValue);
      await score.updateHighScoreIfNeeded();

      score.addMinerals(upgrade.cost);
      upgradeService.buy(upgrade);

      expect(score.hitPlayer(), isFalse);
      expect(score.health.value, Constants.playerMaxHealth - 1);

      score.reset();

      expect(score.score.value, 0);
      expect(score.minerals.value, 0);
      expect(score.health.value, Constants.playerMaxHealth);
      expect(score.highScore.value, scoreValue);
      expect(upgradeService.isPurchased(upgrade.id), isTrue);

      final restartedStorage = await _createStorage();
      final restartedScore = _createScore(restartedStorage);
      final restartedUpgradeService =
          _createUpgradeService(restartedScore, restartedStorage);

      expect(restartedScore.score.value, 0);
      expect(restartedScore.highScore.value, scoreValue);
      expect(restartedScore.health.value, Constants.playerMaxHealth);
      expect(restartedUpgradeService.isPurchased(upgrade.id), isTrue);

      expect(await restartedScore.resetHighScore(), isTrue);
      expect(restartedScore.highScore.value, 0);
      expect(restartedStorage.getHighScore(), 0);
    });

    test('ScoreService retains high score when storage write fails', () async {
      final storage = await _createFailingStorage({});
      final score = _createScore(storage);

      score.addScore(10);
      await score.updateHighScoreIfNeeded();
      expect(score.highScore.value, 0);
    });

    test('ScoreService retains high score when reset fails', () async {
      final storage = await _createFailingStorage({'highScore': 42});
      final score = _createScore(storage);

      expect(score.highScore.value, 42);
      expect(await score.resetHighScore(), isFalse);
      expect(score.highScore.value, 42);
    });
  });
}
