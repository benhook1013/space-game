import '../components/asteroid.dart';
import '../components/bullet.dart';
import '../components/mineral.dart';
import '../components/enemy.dart';
import '../game/space_game.dart';

/// Handles start, menu, and game over transitions.
class LifecycleManager {
  LifecycleManager(this.game);

  final SpaceGame game;

  void onStart() {
    game.scoreService.reset();
    for (final enemy in game.pools.enemies.toList()) {
      enemy.removeFromParent();
    }
    for (final asteroid in game.pools.asteroids.toList()) {
      asteroid.removeFromParent();
    }
    for (final mineral in game.pools.mineralPickups.toList()) {
      mineral.removeFromParent();
    }
    game.children
        .whereType<BulletComponent>()
        .forEach((b) => b.removeFromParent());
    if (!game.player.isMounted) {
      game.add(game.player);
      game.camera.follow(game.player);
    }
    game.player.setSprite(game.selectedPlayerSprite);
    game.player.reset();
    game.enemySpawner
      ..stop()
      ..start();
    game.asteroidSpawner
      ..stop()
      ..start();
    game.resumeEngine();
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
