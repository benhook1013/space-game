import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';
import 'enemy.dart';

/// Spawns enemies at timed intervals when started.
class EnemySpawner extends Component with HasGameReference<SpaceGame> {
  EnemySpawner();

  final math.Random _random = math.Random();
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
    final spawnDistance = Constants.despawnRadius * 0.9;
    Vector2 base;
    if (game.player.isMoving) {
      final dir = Vector2(
        math.cos(game.player.angle - math.pi / 2),
        math.sin(game.player.angle - math.pi / 2),
      );
      base = game.player.position + dir * spawnDistance;
    } else {
      final angle = _random.nextDouble() * math.pi * 2;
      base = game.player.position +
          Vector2(math.cos(angle), math.sin(angle)) * spawnDistance;
    }
    final faction = Assets.randomFaction();
    for (var i = 0; i < Constants.enemyGroupSize; i++) {
      final offset = (Vector2.random(_random) - Vector2.all(0.5)) *
          (Constants.enemyGroupSpread * 2);
      final position = base + offset;
      game.add(
        game.pools.acquire<EnemyComponent>((e) => e.reset(position, faction)),
      );
    }
    if (_random.nextDouble() < Constants.enemyBossChance) {
      game.add(
        game.pools.acquire<EnemyComponent>(
          (e) => e.reset(base, faction, isBoss: true),
        ),
      );
    }
  }

  @visibleForTesting
  void spawnNow() => _spawn();

  @visibleForTesting
  bool get isRunning => _timer.isRunning();
}
