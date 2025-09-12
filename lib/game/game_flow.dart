import 'dart:async';

import '../components/explosion.dart';
import 'space_game.dart';

/// Handles high-level gameplay flow actions like scoring, damage and state
/// transitions.
class GameFlow {
  GameFlow(this.game);

  final SpaceGame game;

  /// Handles player damage and checks for game over.
  void hitPlayer() {
    if (!game.stateMachine.isPlaying) {
      return;
    }
    game.player.flashDamage();
    if (game.scoreService.hitPlayer()) {
      game.add(ExplosionComponent(position: game.player.position.clone()));
      game.audioService.playExplosion();
      game.player.removeFromParent();
      game.stateMachine.gameOver();
    }
  }

  /// Adds [value] to the current score.
  void addScore(int value) => game.scoreService.addScore(value);

  /// Adds [value] to the current mineral count.
  void addMinerals(int value) => game.scoreService.addMinerals(value);

  /// Resets the shield regeneration timer.
  void resetHealthRegenTimer() => game.healthRegen.reset();

  /// Pauses the game and shows the `PAUSED` overlay.
  void pauseGame() => game.assetLifecycle.pauseGame();

  /// Resumes the game from a paused state.
  void resumeGame() => game.assetLifecycle.resumeGame();

  /// Returns to the main menu without restarting the session.
  void returnToMenu() => game.stateMachine.returnToMenu();

  /// Begins loading assets needed for gameplay.
  ///
  /// Safe to call multiple times; subsequent invocations are ignored.
  void startLoadingAssets() => game.assetLifecycle.startLoadingAssets();

  /// Starts a new game session.
  Future<void> startGame() => game.assetLifecycle.startGame();

  /// Clears the saved high score.
  ///
  /// Returns `true` if the score was removed from storage.
  Future<bool> resetHighScore() => game.scoreService.resetHighScore();

  /// Transitions to the game over state.
  void gameOver() => game.stateMachine.gameOver();
}
