import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/services/score_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/settings_service.dart';
import 'package:space_game/services/upgrade_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buy deducts minerals and marks upgrade purchased', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);
    final settings = SettingsService();
    final service = UpgradeService(
      scoreService: score,
      storageService: storage,
      settingsService: settings,
    );
    score.addMinerals(20);
    final upgrade = service.upgrades.first;
    final success = service.buy(upgrade);
    expect(success, isTrue);
    expect(score.minerals.value, 10);
    expect(service.isPurchased(upgrade.id), isTrue);
  });

  test('buy fails without enough minerals', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);
    final settings = SettingsService();
    final service = UpgradeService(
      scoreService: score,
      storageService: storage,
      settingsService: settings,
    );
    final upgrade = service.upgrades.first;
    final success = service.buy(upgrade);
    expect(success, isFalse);
    expect(score.minerals.value, 0);
  });

  test('purchased upgrades persist to storage', () async {
    SharedPreferences.setMockInitialValues({});
    final storage1 = await StorageService.create();
    final score = ScoreService(storageService: storage1);
    final settings = SettingsService();
    final service = UpgradeService(
      scoreService: score,
      storageService: storage1,
      settingsService: settings,
    );
    final upgrade = service.upgrades.first;
    score.addMinerals(upgrade.cost);
    service.buy(upgrade);

    final storage2 = await StorageService.create();
    final score2 = ScoreService(storageService: storage2);
    final service2 = UpgradeService(
      scoreService: score2,
      storageService: storage2,
      settingsService: settings,
    );
    expect(service2.isPurchased(upgrade.id), isTrue);
  });
}
