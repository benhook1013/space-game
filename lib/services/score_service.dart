import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'storage_service.dart';

/// Tracks score, minerals, health and high score persistence.
class ScoreService {
  ScoreService({required this.storageService}) {
    highScore.value = storageService.getHighScore();
  }

  final StorageService storageService;

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> highScore = ValueNotifier<int>(0);
  final ValueNotifier<int> minerals = ValueNotifier<int>(0);
  final ValueNotifier<int> health =
      ValueNotifier<int>(Constants.playerMaxHealth);

  /// Resets values for a new game.
  void reset() {
    score.value = 0;
    minerals.value = 0;
    health.value = Constants.playerMaxHealth;
  }

  void addScore(int value) => score.value += value;

  void addMinerals(int value) => minerals.value += value;

  /// Returns `true` when health reaches zero.
  bool hitPlayer() {
    health.value -= 1;
    return health.value <= 0;
  }

  /// Clears the high score both in memory and persistent storage.
  ///
  /// Returns `true` if the underlying storage was successfully updated.
  Future<bool> resetHighScore() async {
    highScore.value = 0;
    return storageService.resetHighScore();
  }

  Future<void> updateHighScoreIfNeeded() async {
    if (score.value > highScore.value) {
      highScore.value = score.value;
      await storageService.setHighScore(highScore.value);
    }
  }
}
