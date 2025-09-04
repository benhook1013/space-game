import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/services/score_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/upgrade_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buy deducts minerals and marks upgrade purchased', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final score = ScoreService(storageService: storage);
    final service = UpgradeService(scoreService: score);
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
    final service = UpgradeService(scoreService: score);
    final upgrade = service.upgrades.first;
    final success = service.buy(upgrade);
    expect(success, isFalse);
    expect(score.minerals.value, 0);
  });
}
