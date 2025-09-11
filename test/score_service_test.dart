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

  test('hitPlayer clamps health at zero', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);

    for (var i = 0; i < Constants.playerMaxHealth; i++) {
      score.hitPlayer();
    }

    expect(score.health.value, 0);
    expect(score.hitPlayer(), isTrue);
    expect(score.health.value, 0);
  });
}
