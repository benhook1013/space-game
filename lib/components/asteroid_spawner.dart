import 'dart:math';

import 'package:flame/components.dart';

import '../constants.dart';
import '../game/space_game.dart';

/// Spawns asteroids at timed intervals when started.
class AsteroidSpawner extends Component with HasGameRef<SpaceGame> {
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
    final x = _random.nextDouble() * Constants.worldSize.x;
    final vx = (_random.nextDouble() - 0.5) * Constants.asteroidSpeed;
    gameRef.add(
      gameRef.acquireAsteroid(
        Vector2(x, -Constants.asteroidSize * Constants.asteroidScale),
        Vector2(vx, Constants.asteroidSpeed),
      ),
    );
  }
}
