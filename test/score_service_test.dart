import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/constants.dart';
import 'package:space_game/services/score_service.dart';
import 'package:space_game/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reset restores default values', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);

    score.addScore(5);
    score.addMinerals(3);
    score.hitPlayer();
    expect(score.score.value, 5);
    expect(score.minerals.value, 3);
    expect(score.health.value, Constants.playerMaxHealth - 1);

    score.reset();
    expect(score.score.value, 0);
    expect(score.minerals.value, 0);
    expect(score.health.value, Constants.playerMaxHealth);
  });

  test('updates and resets high score', () async {
    SharedPreferences.setMockInitialValues({'highScore': 10});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);

    expect(score.highScore.value, 10);

    score.addScore(15);
    await score.updateHighScoreIfNeeded();
    expect(score.highScore.value, 15);
    expect(storage.getHighScore(), 15);

    expect(await score.resetHighScore(), isTrue);
    expect(score.highScore.value, 0);
    expect(storage.getHighScore(), 0);
  });
}
