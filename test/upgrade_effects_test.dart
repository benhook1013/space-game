import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/constants.dart';
import 'package:space_game/services/score_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/settings_service.dart';
import 'package:space_game/services/upgrade_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Faster Cannon reduces bullet cooldown', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);
    final settings = SettingsService();
    final service = UpgradeService(
      scoreService: score,
      storageService: storage,
      settingsService: settings,
    );
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
    final settings = SettingsService();
    final service = UpgradeService(
      scoreService: score,
      storageService: storage,
      settingsService: settings,
    );
    final upgrade = service.upgrades.firstWhere((u) => u.id == 'miningSpeed1');
    expect(service.miningPulseInterval, Constants.miningPulseInterval);
    score.addMinerals(upgrade.cost);
    service.buy(upgrade);
    expect(
        service.miningPulseInterval, lessThan(Constants.miningPulseInterval));
  });

  test('Targeting Computer increases auto-aim range', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);
    final settings = SettingsService();
    final service = UpgradeService(
      scoreService: score,
      storageService: storage,
      settingsService: settings,
    );
    final upgrade =
        service.upgrades.firstWhere((u) => u.id == 'targetingRange1');
    expect(service.targetingRange, Constants.playerAutoAimRange);
    score.addMinerals(upgrade.cost);
    service.buy(upgrade);
    expect(service.targetingRange, greaterThan(Constants.playerAutoAimRange));
  });

  test('Tractor Booster extends Tractor Aura radius', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);
    final settings = SettingsService();
    final service = UpgradeService(
      scoreService: score,
      storageService: storage,
      settingsService: settings,
    );
    final upgrade = service.upgrades.firstWhere((u) => u.id == 'tractorRange1');
    expect(service.tractorRange, Constants.playerTractorAuraRadius);
    score.addMinerals(upgrade.cost);
    service.buy(upgrade);
    expect(
        service.tractorRange, greaterThan(Constants.playerTractorAuraRadius));
  });

  test('Engine Tuning increases player speed', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);
    final settings = SettingsService();
    final service = UpgradeService(
      scoreService: score,
      storageService: storage,
      settingsService: settings,
    );
    final upgrade = service.upgrades.firstWhere((u) => u.id == 'speed1');
    expect(service.playerSpeed, Constants.playerSpeed);
    score.addMinerals(upgrade.cost);
    service.buy(upgrade);
    expect(service.playerSpeed, greaterThan(Constants.playerSpeed));
  });
}
