import 'dart:async';

import '../game/space_game.dart';
import '../components/explosion.dart';
import '../components/player.dart';
import '../components/mining_laser.dart';

/// Handles start, menu, and game over transitions.
class LifecycleManager {
  LifecycleManager(this.game);

  final SpaceGame game;

  void onStart() {
    game.audioService.stopAll();
    game.scoreService.reset();
    game.pools.clear();
    // Process any queued lifecycle events so components added just before the
    // previous session ended (like the player's explosion on death) are
    // mounted and can be removed before the new run begins.
    game.processLifecycleEvents();
    // Remove any lingering explosions from a previous session.
    for (final explosion in List<ExplosionComponent>.from(
      game.children.whereType<ExplosionComponent>(),
    )) {
      explosion.removeFromParent();
    }
    // Ensure any previous player instances are fully removed before starting.
    for (final player in List<PlayerComponent>.from(
      game.children.whereType<PlayerComponent>(),
    )) {
      player.removeFromParent();
    }
    if (game.player.isRemoving || !game.player.isMounted) {
      // Previous player is pending removal; create a fresh instance.
      final player = PlayerComponent(
        joystick: game.joystick,
        keyDispatcher: game.keyDispatcher,
        spritePath: game.selectedPlayerSprite,
      )..reset();
      game.player = player;
      final addResult = game.add(player);
      if (addResult is Future<void>) {
        unawaited(addResult.then((_) => player.resetInput()));
      } else {
        player.resetInput();
      }
      // Recreate the mining laser for the new player.
      game.miningLaser?.removeFromParent();
      final laser = MiningLaserComponent(player: player);
      game.miningLaser = laser;
      game.add(laser);
      // Update fire button callbacks.
      game.fireButton
        ..onPressed = player.startShooting
        ..onReleased = player.stopShooting;
    } else {
      game.player.setSprite(game.selectedPlayerSprite);
      game.player.reset();
    }
    game.camera.follow(game.player, snap: true);
    game.enemySpawner
      ..stop()
      ..start();
    game.asteroidSpawner
      ..stop()
      ..start();
    game.resumeEngine();
    game.focusGame();
  }

  void onGameOver() {
    game.enemySpawner.stop();
    game.asteroidSpawner.stop();
    game.scoreService.updateHighScoreIfNeeded();
    game.audioService.stopAll();
    game.pauseEngine();
  }

  void onMenu() {
    game.enemySpawner.stop();
    game.asteroidSpawner.stop();
    game.audioService.stopAll();
    game.pauseEngine();
  }
}
