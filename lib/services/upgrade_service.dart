import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'score_service.dart';
import 'settings_service.dart';
import 'storage_service.dart';

/// Simple upgrade data.
class Upgrade {
  Upgrade({required this.id, required this.name, required this.cost});

  final String id;
  final String name;
  final int cost;
}

/// Handles purchasing upgrades with minerals.
class UpgradeService {
  UpgradeService({
    required this.scoreService,
    required this.storageService,
    required this.settingsService,
  }) {
    final saved = storageService.getStringList(_purchasedUpgradesKey, []);
    _purchased.value = saved.toSet();
  }

  final ScoreService scoreService;
  final StorageService storageService;
  final SettingsService settingsService;

  static const _purchasedUpgradesKey = 'purchasedUpgrades';

  final List<Upgrade> upgrades = [
    Upgrade(id: 'fireRate1', name: 'Faster Cannon', cost: 10),
    Upgrade(id: 'miningSpeed1', name: 'Efficient Mining', cost: 15),
    Upgrade(id: 'targetingRange1', name: 'Targeting Computer', cost: 20),
    Upgrade(id: 'tractorRange1', name: 'Tractor Booster', cost: 25),
    Upgrade(id: 'speed1', name: 'Engine Tuning', cost: 30),
    Upgrade(id: 'shieldRegen1', name: 'Shield Booster', cost: 40),
  ];

  final ValueNotifier<Set<String>> _purchased =
      ValueNotifier<Set<String>>(<String>{});
  ValueListenable<Set<String>> get purchased => _purchased;

  bool isPurchased(String id) => _purchased.value.contains(id);

  /// Whether the shield regeneration upgrade has been purchased.
  bool get hasShieldRegen => isPurchased('shieldRegen1');

  bool canAfford(Upgrade upgrade) =>
      scoreService.minerals.value >= upgrade.cost && !isPurchased(upgrade.id);

  /// Current bullet cooldown factoring in purchased upgrades.
  double get bulletCooldown {
    var cooldown = Constants.bulletCooldown;
    if (isPurchased('fireRate1')) {
      cooldown *= Constants.bulletCooldownUpgradeFactor;
    }
    return cooldown;
  }

  /// Current mining pulse interval factoring in purchased upgrades.
  double get miningPulseInterval {
    var interval = Constants.miningPulseInterval;
    if (isPurchased('miningSpeed1')) {
      interval *= Constants.miningPulseIntervalUpgradeFactor;
    }
    return interval;
  }

  /// Current auto-aim targeting range factoring in purchased upgrades.
  double get targetingRange {
    var range = settingsService.targetingRange.value;
    if (isPurchased('targetingRange1')) {
      range *= Constants.targetingRangeUpgradeFactor;
    }
    return range;
  }

  /// Current Tractor Aura radius factoring in purchased upgrades.
  double get tractorRange {
    var range = settingsService.tractorRange.value;
    if (isPurchased('tractorRange1')) {
      range *= Constants.tractorRangeUpgradeFactor;
    }
    return range;
  }

  /// Current player movement speed factoring in purchased upgrades.
  double get playerSpeed {
    var speed = Constants.playerSpeed;
    if (isPurchased('speed1')) {
      speed *= Constants.playerSpeedUpgradeFactor;
    }
    return speed;
  }

  /// Attempts to buy [upgrade], returning `true` on success.
  bool buy(Upgrade upgrade) {
    if (!canAfford(upgrade)) {
      return false;
    }
    scoreService.addMinerals(-upgrade.cost);
    final newSet = Set<String>.from(_purchased.value)..add(upgrade.id);
    _purchased.value = newSet;
    storageService.setStringList(
      _purchasedUpgradesKey,
      _purchased.value.toList(),
    );
    return true;
  }

  /// Releases resources held by the service.
  void dispose() {
    _purchased.dispose();
  }
}
