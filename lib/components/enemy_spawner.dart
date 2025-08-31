import 'dart:math';

import 'package:flame/components.dart';

import '../constants.dart';
import '../game/space_game.dart';

/// Spawns enemies at timed intervals when started.
class EnemySpawner extends Component with HasGameReference<SpaceGame> {
  EnemySpawner();

  final Random _random = Random();
  final Timer _timer = Timer(Constants.enemySpawnInterval, repeat: true);

  /// Starts spawning enemies.
  void start() => _timer.start();

  /// Stops spawning enemies.
  void stop() => _timer.stop();

  @override
  Future<void> onMount() async {
    _timer.onTick = _spawn;
    return super.onMount();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
  }

  void _spawn() {
    final x = _random.nextDouble() * Constants.worldSize.x;
    gameRef.add(
      gameRef.acquireEnemy(
        Vector2(x, -Constants.enemySize * Constants.enemyScale),
      ),
    );
  }
}
