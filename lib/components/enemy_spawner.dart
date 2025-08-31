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
    final spawnDistance =
        Constants.enemySize * (Constants.spriteScale + Constants.enemyScale);
    final rect = game.camera.visibleWorldRect;
    final edge = _random.nextInt(4);
    late Vector2 position;
    switch (edge) {
      case 0: // top
        position = Vector2(
          rect.left + _random.nextDouble() * rect.width,
          rect.top - spawnDistance,
        );
        break;
      case 1: // bottom
        position = Vector2(
          rect.left + _random.nextDouble() * rect.width,
          rect.bottom + spawnDistance,
        );
        break;
      case 2: // left
        position = Vector2(
          rect.left - spawnDistance,
          rect.top + _random.nextDouble() * rect.height,
        );
        break;
      default: // right
        position = Vector2(
          rect.right + spawnDistance,
          rect.top + _random.nextDouble() * rect.height,
        );
    }
    position.clamp(Vector2.zero(), Constants.worldSize);
    game.add(
      game.acquireEnemy(position),
    );
  }
}
