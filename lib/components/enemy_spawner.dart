import 'dart:math';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

import '../constants.dart';
import '../game/space_game.dart';
import 'enemy.dart';

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
    late Vector2 base;
    switch (edge) {
      case 0: // top
        base = Vector2(
          rect.left + _random.nextDouble() * rect.width,
          rect.top - spawnDistance,
        );
        break;
      case 1: // bottom
        base = Vector2(
          rect.left + _random.nextDouble() * rect.width,
          rect.bottom + spawnDistance,
        );
        break;
      case 2: // left
        base = Vector2(
          rect.left - spawnDistance,
          rect.top + _random.nextDouble() * rect.height,
        );
        break;
      default: // right
        base = Vector2(
          rect.right + spawnDistance,
          rect.top + _random.nextDouble() * rect.height,
        );
    }
    for (var i = 0; i < Constants.enemyGroupSize; i++) {
      final offset = (Vector2.random(_random) - Vector2.all(0.5)) *
          (Constants.enemyGroupSpread * 2);
      final position = base + offset;
      game.add(
        game.pools.acquire<EnemyComponent>((e) => e.reset(position)),
      );
    }
  }

  @visibleForTesting
  void spawnNow() => _spawn();
}
