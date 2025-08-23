import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show EdgeInsets;

import '../components/asteroid.dart';
import '../components/enemy.dart';
import '../components/bullet.dart';
import '../components/player.dart';
import '../components/starfield.dart';
import '../constants.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../ui/game_over_overlay.dart';
import '../ui/hud_overlay.dart';
import '../ui/menu_overlay.dart';
import 'game_state.dart';

/// Root Flame game handling the core loop.
class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  SpaceGame({required this.storageService, required this.audioService});

  /// Handles persistence for the high score.
  final StorageService storageService;

  /// Plays sound effects and handles the mute toggle.
  final AudioService audioService;

  GameState state = GameState.menu;
  late final PlayerComponent player;
  late final JoystickComponent joystick;
  late final HudButtonComponent fireButton;
  late final Timer _enemySpawnTimer;
  late final Timer _asteroidSpawnTimer;
  final Random _random = Random();

  /// Current score exposed to Flutter overlays.
  final ValueNotifier<int> score = ValueNotifier<int>(0);

  /// Highest score persisted across sessions.
  final ValueNotifier<int> highScore = ValueNotifier<int>(0);

  @override
  Future<void> onLoad() async {
    add(StarfieldComponent());
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

    _enemySpawnTimer = Timer(2, onTick: _spawnEnemy, repeat: true);
    _asteroidSpawnTimer = Timer(3, onTick: _spawnAsteroid, repeat: true);

    highScore.value = storageService.getHighScore();

    pauseEngine();
    overlays.add(MenuOverlay.id);
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

  /// Adds [value] to the current score.
  void addScore(int value) {
    score.value += value;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state == GameState.playing) {
      _enemySpawnTimer.update(dt);
      _asteroidSpawnTimer.update(dt);
    }
  }

  /// Starts a new game session.
  void startGame() {
    state = GameState.playing;
    score.value = 0;
    children.whereType<EnemyComponent>().forEach((e) => e.removeFromParent());
    children.whereType<AsteroidComponent>().forEach(
      (a) => a.removeFromParent(),
    );
    children.whereType<BulletComponent>().forEach((b) => b.removeFromParent());
    player.position = size / 2;
    overlays
      ..remove(MenuOverlay.id)
      ..remove(GameOverOverlay.id)
      ..add(HudOverlay.id);
    _enemySpawnTimer
      ..stop()
      ..start();
    _asteroidSpawnTimer
      ..stop()
      ..start();
    resumeEngine();
  }

  /// Transitions to the game over state.
  void gameOver() {
    state = GameState.gameOver;
    if (score.value > highScore.value) {
      highScore.value = score.value;
      storageService.setHighScore(highScore.value);
    }
    overlays
      ..remove(HudOverlay.id)
      ..add(GameOverOverlay.id);
    pauseEngine();
  }
}
