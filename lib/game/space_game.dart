import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
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
import '../assets.dart';
import '../components/player.dart';
import '../components/starfield.dart';
import '../components/mining_laser.dart';
import '../constants.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../ui/game_over_overlay.dart';
import '../ui/hud_overlay.dart';
import '../ui/menu_overlay.dart';
import '../ui/pause_overlay.dart';
import '../ui/help_overlay.dart';
import 'game_state.dart';

/// Root Flame game handling the core loop.
///
/// [HasKeyboardHandlerComponents] already exposes [KeyboardEvents] and
/// propagates key presses to child components like the player. Mixing in the
/// standalone [KeyboardEvents] here would prevent that propagation, so it is
/// intentionally omitted.
class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  SpaceGame({required this.storageService, required this.audioService}) {
    debugMode = kDebugMode;
  }

  /// Handles persistence for the high score.
  final StorageService storageService;

  /// Plays sound effects and handles the mute toggle.
  final AudioService audioService;

  GameState state = GameState.menu;
  late final PlayerComponent player;
  late final MiningLaserComponent miningLaser;
  late final JoystickComponent joystick;
  late final HudButtonComponent fireButton;
  late final Timer _enemySpawnTimer;
  late final Timer _asteroidSpawnTimer;
  final Random _random = Random();
  FpsTextComponent? _fpsText;

  /// Current score exposed to Flutter overlays.
  final ValueNotifier<int> score = ValueNotifier<int>(0);

  /// Highest score persisted across sessions.
  final ValueNotifier<int> highScore = ValueNotifier<int>(0);

  /// Minerals collected from asteroids.
  final ValueNotifier<int> minerals = ValueNotifier<int>(0);

  /// Player health exposed for HUD rendering.
  final ValueNotifier<int> health = ValueNotifier<int>(
    Constants.playerMaxHealth,
  );

  /// Selected player sprite index for menu selection.
  final ValueNotifier<int> selectedPlayerIndex = ValueNotifier<int>(0);

  String get selectedPlayerSprite => Assets.players[selectedPlayerIndex.value];

  void selectPlayer(int index) {
    selectedPlayerIndex.value = index.clamp(0, Assets.players.length - 1);
  }

  /// Pool of reusable bullets.
  final List<BulletComponent> _bulletPool = [];

  /// Pool of reusable asteroids.
  final List<AsteroidComponent> _asteroidPool = [];

  /// Pool of reusable enemies.
  final List<EnemyComponent> _enemyPool = [];

  /// Tracks whether the game was playing when the help overlay opened.
  bool _helpWasPlaying = false;

  @override
  Future<void> onLoad() async {
    add(StarfieldComponent());
    if (kDebugMode) {
      _fpsText = FpsTextComponent(position: Vector2.all(10));
      await add(_fpsText!);
    }
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

    player =
        PlayerComponent(joystick: joystick, spritePath: selectedPlayerSprite);
    add(player);
    camera.follow(player);
    miningLaser = MiningLaserComponent(player: player);
    add(miningLaser);

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

    _enemySpawnTimer = Timer(
      Constants.enemySpawnInterval,
      onTick: _spawnEnemy,
      repeat: true,
    );
    _asteroidSpawnTimer = Timer(
      Constants.asteroidSpawnInterval,
      onTick: _spawnAsteroid,
      repeat: true,
    );

    highScore.value = storageService.getHighScore();

    pauseEngine();
    overlays.add(MenuOverlay.id);
  }

  void _spawnEnemy() {
    final x = _random.nextDouble() * size.x;
    add(
      acquireEnemy(
        Vector2(x, -Constants.enemySize * Constants.enemyScale),
      ),
    );
  }

  void _spawnAsteroid() {
    final x = _random.nextDouble() * size.x;
    final vx = (_random.nextDouble() - 0.5) * Constants.asteroidSpeed;
    add(
      acquireAsteroid(
        Vector2(x, -Constants.asteroidSize * Constants.asteroidScale),
        Vector2(vx, Constants.asteroidSpeed),
      ),
    );
  }

  /// Retrieves a bullet from the pool or creates a new one.
  BulletComponent acquireBullet(Vector2 position, Vector2 direction) {
    final bullet =
        _bulletPool.isNotEmpty ? _bulletPool.removeLast() : BulletComponent();
    bullet.reset(position, direction);
    return bullet;
  }

  /// Returns [bullet] to the pool for reuse.
  void releaseBullet(BulletComponent bullet) {
    _bulletPool.add(bullet);
  }

  /// Retrieves an asteroid from the pool or creates a new one.
  AsteroidComponent acquireAsteroid(Vector2 position, Vector2 velocity) {
    final asteroid = _asteroidPool.isNotEmpty
        ? _asteroidPool.removeLast()
        : AsteroidComponent();
    asteroid.reset(position, velocity);
    return asteroid;
  }

  /// Returns [asteroid] to the pool for reuse.
  void releaseAsteroid(AsteroidComponent asteroid) {
    _asteroidPool.add(asteroid);
  }

  /// Retrieves an enemy from the pool or creates a new one.
  EnemyComponent acquireEnemy(Vector2 position) {
    final enemy =
        _enemyPool.isNotEmpty ? _enemyPool.removeLast() : EnemyComponent();
    enemy.reset(position);
    return enemy;
  }

  /// Returns [enemy] to the pool for reuse.
  void releaseEnemy(EnemyComponent enemy) {
    _enemyPool.add(enemy);
  }

  /// Toggles the help overlay and pauses/resumes if entering from gameplay.
  void toggleHelp() {
    if (overlays.isActive(HelpOverlay.id)) {
      overlays.remove(HelpOverlay.id);
      if (_helpWasPlaying) {
        resumeEngine();
      }
    } else {
      _helpWasPlaying = state == GameState.playing;
      overlays.add(HelpOverlay.id);
      if (_helpWasPlaying) {
        pauseEngine();
      }
    }
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

  /// Adds [value] to the current mineral count.
  void addMinerals(int value) {
    minerals.value += value;
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
    minerals.value = 0;
    health.value = Constants.playerMaxHealth;
    children.whereType<EnemyComponent>().forEach((e) => e.removeFromParent());
    children.whereType<AsteroidComponent>().forEach(
          (a) => a.removeFromParent(),
        );
    children.whereType<BulletComponent>().forEach((b) => b.removeFromParent());
    if (!player.isMounted) {
      add(player);
      camera.follow(player);
    }
    player.setSprite(selectedPlayerSprite);
    player.reset();
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

  /// Clears the saved high score.
  Future<void> resetHighScore() async {
    highScore.value = 0;
    await storageService.resetHighScore();
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

  /// Toggles debug rendering and FPS overlay.
  void toggleDebug() {
    debugMode = !debugMode;
    if (debugMode) {
      if (_fpsText != null && !_fpsText!.isMounted) {
        add(_fpsText!);
      }
    } else {
      _fpsText?.removeFromParent();
    }
  }

  /// Toggles rendering of the player's auto-aim radius.
  void toggleAutoAimRadius() {
    player.toggleAutoAimRadius();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (overlays.isActive(HelpOverlay.id) &&
          (event.logicalKey == LogicalKeyboardKey.escape ||
              event.logicalKey == LogicalKeyboardKey.keyH)) {
        toggleHelp();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (state == GameState.playing) {
          pauseGame();
          return KeyEventResult.handled;
        } else if (state == GameState.paused) {
          resumeGame();
          return KeyEventResult.handled;
        } else if (state == GameState.gameOver) {
          returnToMenu();
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyP) {
        if (state == GameState.playing) {
          pauseGame();
          return KeyEventResult.handled;
        } else if (state == GameState.paused) {
          resumeGame();
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
        audioService.toggleMute();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (state == GameState.menu || state == GameState.gameOver) {
          startGame();
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
        if (state == GameState.gameOver ||
            state == GameState.playing ||
            state == GameState.paused) {
          startGame();
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyQ) {
        if (state == GameState.paused || state == GameState.gameOver) {
          returnToMenu();
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
        toggleHelp();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.f1) {
        toggleDebug();
        return KeyEventResult.handled;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
