import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'score_service.dart';

/// Simple upgrade data.
class Upgrade {
  Upgrade({required this.id, required this.name, required this.cost});

  final String id;
  final String name;
  final int cost;
}

/// Handles purchasing upgrades with minerals.
class UpgradeService {
  UpgradeService({required this.scoreService});

  final ScoreService scoreService;

  final List<Upgrade> upgrades = [
    Upgrade(id: 'fireRate1', name: 'Faster Cannon', cost: 10),
    Upgrade(id: 'miningSpeed1', name: 'Efficient Mining', cost: 15),
  ];

  final ValueNotifier<Set<String>> _purchased =
      ValueNotifier<Set<String>>(<String>{});
  ValueListenable<Set<String>> get purchased => _purchased;

  bool isPurchased(String id) => _purchased.value.contains(id);

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

  /// Attempts to buy [upgrade], returning `true` on success.
  bool buy(Upgrade upgrade) {
    if (!canAfford(upgrade)) {
      return false;
    }
    scoreService.addMinerals(-upgrade.cost);
    final newSet = Set<String>.from(_purchased.value)..add(upgrade.id);
    _purchased.value = newSet;
    return true;
  }
}
