import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/services.dart'
    show KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart' show KeyEventResult;

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
import '../ui/pause_overlay.dart';
import 'game_state.dart';

/// Root Flame game handling the core loop.
class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection, KeyboardEvents {
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

  /// Player health exposed for HUD rendering.
  final ValueNotifier<int> health = ValueNotifier<int>(
    Constants.playerMaxHealth,
  );

  /// Pool of reusable bullets.
  final List<BulletComponent> _bulletPool = [];

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(Constants.logicalWidth, Constants.logicalHeight),
    );
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
    camera.follow(player);

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

  /// Retrieves a bullet from the pool or creates a new one.
  BulletComponent acquireBullet(Vector2 position, Vector2 direction) {
    final bullet = _bulletPool.isNotEmpty
        ? _bulletPool.removeLast()
        : BulletComponent();
    bullet.reset(position, direction);
    return bullet;
  }

  /// Returns [bullet] to the pool for reuse.
  void releaseBullet(BulletComponent bullet) {
    _bulletPool.add(bullet);
  }

  /// Handles player damage and checks for game over.
  void hitPlayer() {
    if (state != GameState.playing) {
      return;
    }
    health.value -= 1;
    if (health.value <= 0) {
      gameOver();
    }
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

  /// Pauses the game and shows the pause overlay.
  void pauseGame() {
    if (state != GameState.playing) {
      return;
    }
    state = GameState.paused;
    overlays
      ..remove(HudOverlay.id)
      ..add(PauseOverlay.id);
    pauseEngine();
  }

  /// Resumes the game from a paused state.
  void resumeGame() {
    if (state != GameState.paused) {
      return;
    }
    state = GameState.playing;
    overlays
      ..remove(PauseOverlay.id)
      ..add(HudOverlay.id);
    resumeEngine();
  }

  /// Returns to the main menu without restarting the session.
  void returnToMenu() {
    state = GameState.menu;
    overlays
      ..remove(HudOverlay.id)
      ..remove(PauseOverlay.id)
      ..remove(GameOverOverlay.id)
      ..add(MenuOverlay.id);
    _enemySpawnTimer.stop();
    _asteroidSpawnTimer.stop();
    pauseEngine();
  }

  /// Starts a new game session.
  void startGame() {
    state = GameState.playing;
    score.value = 0;
    health.value = Constants.playerMaxHealth;
    children.whereType<EnemyComponent>().forEach((e) => e.removeFromParent());
    children.whereType<AsteroidComponent>().forEach(
      (a) => a.removeFromParent(),
    );
    children.whereType<BulletComponent>().forEach((b) => b.removeFromParent());
    player.position = size / 2;
    overlays
      ..remove(MenuOverlay.id)
      ..remove(GameOverOverlay.id)
      ..remove(PauseOverlay.id)
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
      ..remove(PauseOverlay.id)
      ..add(GameOverOverlay.id);
    pauseEngine();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (state == GameState.playing) {
        pauseGame();
        return KeyEventResult.handled;
      } else if (state == GameState.paused) {
        resumeGame();
        return KeyEventResult.handled;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
