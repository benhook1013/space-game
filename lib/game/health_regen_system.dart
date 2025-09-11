import '../constants.dart';
import '../services/score_service.dart';
import '../services/upgrade_service.dart';

/// Handles passive player health regeneration when the relevant upgrade is active.
class HealthRegenSystem {
  HealthRegenSystem({
    required this.scoreService,
    required this.upgradeService,
  });

  final ScoreService scoreService;
  final UpgradeService upgradeService;

  double _timer = 0;

  /// Resets the regeneration timer, typically when the player is damaged.
  void reset() => _timer = 0;

  /// Updates the regeneration timer and applies healing when appropriate.
  void update(double dt, bool isPlaying) {
    if (isPlaying &&
        upgradeService.hasShieldRegen &&
        scoreService.health.value < Constants.playerMaxHealth) {
      _timer += dt;
      if (_timer >= Constants.playerHealthRegenInterval) {
        _timer = 0;
        scoreService.health.value =
            (scoreService.health.value + 1).clamp(0, Constants.playerMaxHealth);
      }
    } else {
      _timer = 0;
    }
  }
}
