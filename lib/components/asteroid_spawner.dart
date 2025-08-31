import 'dart:math';

import 'package:flame/components.dart';

import '../constants.dart';
import '../game/space_game.dart';

/// Spawns asteroids at timed intervals when started.
class AsteroidSpawner extends Component with HasGameReference<SpaceGame> {
  AsteroidSpawner();

  final Random _random = Random();
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
    final spawnDistance = Constants.asteroidSize * Constants.asteroidScale;
    final edge = _random.nextInt(4);
    late Vector2 position;
    late Vector2 velocity;
    switch (edge) {
      case 0: // top
        position = Vector2(
          _random.nextDouble() * Constants.worldSize.x,
          -spawnDistance,
        );
        velocity = Vector2(
          (_random.nextDouble() - 0.5) * Constants.asteroidSpeed,
          Constants.asteroidSpeed,
        );
        break;
      case 1: // bottom
        position = Vector2(
          _random.nextDouble() * Constants.worldSize.x,
          Constants.worldSize.y + spawnDistance,
        );
        velocity = Vector2(
          (_random.nextDouble() - 0.5) * Constants.asteroidSpeed,
          -Constants.asteroidSpeed,
        );
        break;
      case 2: // left
        position = Vector2(
          -spawnDistance,
          _random.nextDouble() * Constants.worldSize.y,
        );
        velocity = Vector2(
          Constants.asteroidSpeed,
          (_random.nextDouble() - 0.5) * Constants.asteroidSpeed,
        );
        break;
      default: // right
        position = Vector2(
          Constants.worldSize.x + spawnDistance,
          _random.nextDouble() * Constants.worldSize.y,
        );
        velocity = Vector2(
          -Constants.asteroidSpeed,
          (_random.nextDouble() - 0.5) * Constants.asteroidSpeed,
        );
    }
    game.add(
      game.acquireAsteroid(position, velocity),
    );
  }
}
