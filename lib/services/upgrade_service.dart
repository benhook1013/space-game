import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'score_service.dart';
import 'settings_service.dart';
import 'storage_service.dart';

/// Identifiers for purchasable upgrades.
enum UpgradeId {
  fireRate1,
  miningSpeed1,
  targetingRange1,
  tractorRange1,
  speed1,
  shieldRegen1,
}

/// Simple upgrade data.
@immutable
class Upgrade {
  /// Creates an immutable upgrade definition.
  const Upgrade({required this.id, required this.name, required this.cost});

  final UpgradeId id;
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
    _purchased.value =
        saved.map((name) => UpgradeId.values.byName(name)).toSet();
  }

  final ScoreService scoreService;
  final StorageService storageService;
  final SettingsService settingsService;

  static const _purchasedUpgradesKey = 'purchasedUpgrades';

  /// Available upgrades, exposed as an unmodifiable list to prevent runtime
  /// mutation.
  final List<Upgrade> upgrades = List.unmodifiable([
    const Upgrade(id: UpgradeId.fireRate1, name: 'Faster Cannon', cost: 10),
    const Upgrade(
        id: UpgradeId.miningSpeed1, name: 'Efficient Mining', cost: 15),
    const Upgrade(
        id: UpgradeId.targetingRange1, name: 'Targeting Computer', cost: 20),
    const Upgrade(
        id: UpgradeId.tractorRange1, name: 'Tractor Booster', cost: 25),
    const Upgrade(id: UpgradeId.speed1, name: 'Engine Tuning', cost: 30),
    const Upgrade(id: UpgradeId.shieldRegen1, name: 'Shield Booster', cost: 40),
  ]);

  final ValueNotifier<Set<UpgradeId>> _purchased =
      ValueNotifier<Set<UpgradeId>>(<UpgradeId>{});
  ValueListenable<Set<UpgradeId>> get purchased => _purchased;

  bool isPurchased(UpgradeId id) => _purchased.value.contains(id);

  /// Whether the shield regeneration upgrade has been purchased.
  bool get hasShieldRegen => isPurchased(UpgradeId.shieldRegen1);

  bool canAfford(Upgrade upgrade) =>
      scoreService.minerals.value >= upgrade.cost && !isPurchased(upgrade.id);

  /// Current bullet cooldown factoring in purchased upgrades.
  double get bulletCooldown {
    var cooldown = Constants.bulletCooldown;
    if (isPurchased(UpgradeId.fireRate1)) {
      cooldown *= Constants.bulletCooldownUpgradeFactor;
    }
    return cooldown;
  }

  /// Current mining pulse interval factoring in purchased upgrades.
  double get miningPulseInterval {
    var interval = Constants.miningPulseInterval;
    if (isPurchased(UpgradeId.miningSpeed1)) {
      interval *= Constants.miningPulseIntervalUpgradeFactor;
    }
    return interval;
  }

  /// Current auto-aim targeting range factoring in purchased upgrades.
  double get targetingRange {
    var range = settingsService.targetingRange.value;
    if (isPurchased(UpgradeId.targetingRange1)) {
      range *= Constants.targetingRangeUpgradeFactor;
    }
    return range;
  }

  /// Current Tractor Aura radius factoring in purchased upgrades.
  double get tractorRange {
    var range = settingsService.tractorRange.value;
    if (isPurchased(UpgradeId.tractorRange1)) {
      range *= Constants.tractorRangeUpgradeFactor;
    }
    return range;
  }

  /// Current player movement speed factoring in purchased upgrades.
  double get playerSpeed {
    var speed = Constants.playerSpeed;
    if (isPurchased(UpgradeId.speed1)) {
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
    final newSet = Set<UpgradeId>.from(_purchased.value)..add(upgrade.id);
    _purchased.value = newSet;
    storageService.setStringList(
      _purchasedUpgradesKey,
      _purchased.value.map((e) => e.name).toList(),
    );
    return true;
  }

  /// Releases resources held by the service.
  void dispose() {
    _purchased.dispose();
  }
}
