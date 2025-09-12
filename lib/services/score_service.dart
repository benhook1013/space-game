import 'dart:math' as math;

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
    health.value = math.max(0, health.value - 1);
    return health.value == 0;
  }

  /// Clears the high score both in memory and persistent storage.
  ///
  /// Returns `true` if the underlying storage was successfully updated.
  Future<bool> resetHighScore() async {
    final success = await storageService.resetHighScore();
    if (success) {
      highScore.value = 0;
    }
    return success;
  }

  Future<void> updateHighScoreIfNeeded() async {
    final currentScore = score.value;
    if (currentScore > highScore.value) {
      final success = await storageService.setHighScore(currentScore);
      if (success) {
        highScore.value = currentScore;
      }
    }
  }

  /// Releases resources held by the service.
  void dispose() {
    score.dispose();
    highScore.dispose();
    minerals.dispose();
    health.dispose();
  }
}
