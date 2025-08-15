import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/timer.dart';
import 'package:flutter/painting.dart' show EdgeInsets;

import '../assets.dart';
import '../components/enemy.dart';
import '../components/asteroid.dart';
import '../components/player.dart';
import '../constants.dart';
import 'game_state.dart';

/// Root Flame game handling the core loop.
class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  GameState state = GameState.menu;
  late final PlayerComponent player;
  late final JoystickComponent joystick;
  late final HudButtonComponent fireButton;
  late final Timer _enemySpawnTimer;
  late final Timer _asteroidSpawnTimer;
  final Random _random = Random();
  int score = 0;
  late final TextComponent _scoreText;

  @override
  Future<void> onLoad() async {
    await Assets.load();
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 20,
        paint: Paint()..color = const Color(0xffffffff),
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = const Color(0x66ffffff),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);

    player = PlayerComponent(joystick: joystick);
    add(player);

    fireButton = HudButtonComponent(
      button: CircleComponent(
        radius: 30,
        paint: Paint()..color = const Color(0x66ffffff),
      ),
      buttonDown: CircleComponent(
        radius: 30,
        paint: Paint()..color = const Color(0xffffffff),
      ),
      anchor: Anchor.bottomRight,
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: () => player.shoot(),
    );
    add(fireButton);

    _enemySpawnTimer = Timer(2, onTick: _spawnEnemy, repeat: true)..start();
    _asteroidSpawnTimer =
        Timer(3, onTick: _spawnAsteroid, repeat: true)..start();

    _scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2.all(10),
      anchor: Anchor.topLeft,
      priority: 10,
    );
    add(_scoreText);
  }

  void _spawnEnemy() {
    final x = _random.nextDouble() * size.x;
    add(EnemyComponent(position: Vector2(x, -Constants.enemySize)));
  }

  void _spawnAsteroid() {
    final x = _random.nextDouble() * size.x;
    final vx = (_random.nextDouble() - 0.5) * Constants.asteroidSpeed;
    add(
      AsteroidComponent(
        position: Vector2(x, -Constants.asteroidSize),
        velocity: Vector2(vx, Constants.asteroidSpeed),
      ),
    );
  }

  void addScore(int value) {
    score += value;
    _scoreText.text = 'Score: $score';
  }

  @override
  void update(double dt) {
    super.update(dt);
    _enemySpawnTimer.update(dt);
    _asteroidSpawnTimer.update(dt);
  }
}
