import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/constants.dart';
import 'package:space_game/services/score_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/upgrade_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Faster Cannon reduces bullet cooldown', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);
    final service = UpgradeService(scoreService: score);
    final upgrade = service.upgrades.firstWhere((u) => u.id == 'fireRate1');
    expect(service.bulletCooldown, Constants.bulletCooldown);
    score.addMinerals(upgrade.cost);
    service.buy(upgrade);
    expect(service.bulletCooldown, lessThan(Constants.bulletCooldown));
  });

  test('Efficient Mining shortens pulse interval', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);
    final service = UpgradeService(scoreService: score);
    final upgrade = service.upgrades.firstWhere((u) => u.id == 'miningSpeed1');
    expect(service.miningPulseInterval, Constants.miningPulseInterval);
    score.addMinerals(upgrade.cost);
    service.buy(upgrade);
    expect(
        service.miningPulseInterval, lessThan(Constants.miningPulseInterval));
  });
}
