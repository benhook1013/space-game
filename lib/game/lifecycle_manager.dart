import '../game/space_game.dart';

/// Handles start, menu, and game over transitions.
class LifecycleManager {
  LifecycleManager(this.game);

  final SpaceGame game;

  void onStart() {
    game.scoreService.reset();
    game.pools.clear();
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
