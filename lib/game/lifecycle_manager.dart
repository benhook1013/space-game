import '../game/space_game.dart';
import '../components/explosion.dart';
import '../components/player.dart';
import '../components/mining_laser.dart';

/// Handles start, menu, and game over transitions.
class LifecycleManager {
  LifecycleManager(this.game);

  final SpaceGame game;

  void onStart() {
    game.scoreService.reset();
    game.pools.clear();
    // Remove any lingering explosions from a previous session.
    for (final explosion in List<ExplosionComponent>.from(
      game.children.whereType<ExplosionComponent>(),
    )) {
      explosion.removeFromParent();
    }
    if (game.player.isRemoving || !game.player.isMounted) {
      // Previous player is pending removal; create a fresh instance.
      final player = PlayerComponent(
        joystick: game.joystick,
        keyDispatcher: game.keyDispatcher,
        spritePath: game.selectedPlayerSprite,
      )..reset();
      game.player = player;
      game.add(player);
      // Recreate the mining laser for the new player.
      game.miningLaser.removeFromParent();
      game.miningLaser = MiningLaserComponent(player: player);
      game.add(game.miningLaser);
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
    game.pauseEngine();
  }

  void onMenu() {
    game.enemySpawner.stop();
    game.asteroidSpawner.stop();
    game.pauseEngine();
  }
}
