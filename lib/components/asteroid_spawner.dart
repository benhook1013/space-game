import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

import '../constants.dart';
import '../game/space_game.dart';
import 'asteroid.dart';

/// Spawns asteroids at timed intervals when started.
class AsteroidSpawner extends Component with HasGameReference<SpaceGame> {
  AsteroidSpawner();

  final math.Random _random = math.Random();
  final Timer _timer = Timer(Constants.asteroidSpawnInterval, repeat: true);

  void start() => _timer.start();

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
    final spread = Constants.despawnRadius * 0.2;
    Vector2 position;
    Vector2 velocity;
    if (game.player.isMoving) {
      final dir = Vector2(
        math.cos(game.player.angle - math.pi / 2),
        math.sin(game.player.angle - math.pi / 2),
      );
      position = game.player.position + dir * spawnDistance;
      position += (Vector2.random(_random) - Vector2.all(0.5)) * spread;
      velocity = (Vector2.random(_random) - Vector2.all(0.5))
        ..normalize()
        ..scale(Constants.asteroidSpeed);
    } else {
      final angle = _random.nextDouble() * math.pi * 2;
      position = game.player.position +
          Vector2(math.cos(angle), math.sin(angle)) * spawnDistance;
      velocity = (Vector2.random(_random) - Vector2.all(0.5))
        ..normalize()
        ..scale(Constants.asteroidSpeed);
    }
    game.add(
      game.pools.acquire<AsteroidComponent>(
        (a) => a.reset(position, velocity),
      ),
    );
  }

  @visibleForTesting
  bool get isRunning => _timer.isRunning();
}
