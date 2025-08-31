import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import '../components/asteroid.dart';
import '../components/enemy.dart';
import '../components/bullet.dart';
import '../assets.dart';
import '../components/player.dart';
import '../components/mining_laser.dart';
import '../components/enemy_spawner.dart';
import '../components/asteroid_spawner.dart';
import '../components/starfield.dart';
import '../constants.dart';
import '../game/key_dispatcher.dart';
import '../game/game_state_machine.dart';
import '../services/score_service.dart';
import '../services/overlay_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../ui/help_overlay.dart';
import '../ui/upgrades_overlay.dart';
import 'game_state.dart';

/// Root Flame game handling the core loop.
///
/// [HasKeyboardHandlerComponents] already exposes [KeyboardEvents] and
/// propagates key presses to child components like the player. Mixing in the
/// standalone [KeyboardEvents] here would prevent that propagation, so it is
/// intentionally omitted.
class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  SpaceGame({required this.storageService, required this.audioService})
      : scoreService = ScoreService(storageService: storageService) {
    debugMode = kDebugMode;
  }

  /// Handles persistence for the high score.
  final StorageService storageService;

  /// Plays sound effects and handles the mute toggle.
  final AudioService audioService;

  final ScoreService scoreService;
  late final OverlayService overlayService;
  late final GameStateMachine stateMachine;

  late final KeyDispatcher keyDispatcher;
  late final PlayerComponent player;
  late final MiningLaserComponent miningLaser;
  late final JoystickComponent joystick;
  late final HudButtonComponent fireButton;
  late final EnemySpawner enemySpawner;
  late final AsteroidSpawner asteroidSpawner;
  ParallaxComponent? _starfield;
  FpsTextComponent? _fpsText;

  ValueNotifier<int> get score => scoreService.score;
  ValueNotifier<int> get highScore => scoreService.highScore;
  ValueNotifier<int> get minerals => scoreService.minerals;
  ValueNotifier<int> get health => scoreService.health;

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

  /// Active enemies tracked for quick lookup.
  final List<EnemyComponent> enemies = [];

  /// Active asteroids tracked for quick lookup.
  final List<AsteroidComponent> asteroids = [];

  /// TODO: Investigate spatial partitioning (e.g., quad trees) if counts grow.

  /// Tracks whether the game was playing when the help overlay opened.
  bool _helpWasPlaying = false;

  @override
  Future<void> onLoad() async {
    if (kDebugMode) {
      _fpsText = FpsTextComponent(position: Vector2.all(10));
      await add(_fpsText!);
    }

    keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);

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

    _starfield = await createStarfieldParallax(Constants.worldSize);
    add(_starfield!);

    player = PlayerComponent(
      joystick: joystick,
      keyDispatcher: keyDispatcher,
      spritePath: selectedPlayerSprite,
    );
    player.position = Constants.worldSize / 2;
    add(player);
    camera
      ..setBounds(
        Rectangle.fromLTWH(
          0,
          0,
          Constants.worldSize.x,
          Constants.worldSize.y,
        ),
        considerViewport: true,
      )
      ..follow(player);
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

    enemySpawner = EnemySpawner();
    asteroidSpawner = AsteroidSpawner();
    addAll([enemySpawner, asteroidSpawner]);

    overlayService = OverlayService(this);
    stateMachine = GameStateMachine(
      overlays: overlayService,
      onStart: _onStart,
      onPause: pauseEngine,
      onResume: resumeEngine,
      onGameOver: _onGameOver,
      onMenu: _onMenu,
    );

    _registerShortcuts();
    stateMachine.returnToMenu();
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

  /// Toggles the upgrades overlay and pauses/resumes the game.
  void toggleUpgrades() {
    if (overlays.isActive(UpgradesOverlay.id)) {
      overlayService.hideUpgrades();
      stateMachine.state = GameState.playing;
      resumeEngine();
    } else {
      if (stateMachine.state != GameState.playing) {
        return;
      }
      stateMachine.state = GameState.upgrades;
      overlayService.showUpgrades();
      pauseEngine();
    }
  }

  /// Toggles the help overlay and pauses/resumes if entering from gameplay.
  void toggleHelp() {
    if (overlays.isActive(HelpOverlay.id)) {
      overlayService.hideHelp();
      if (_helpWasPlaying) {
        resumeEngine();
      }
    } else {
      _helpWasPlaying = stateMachine.state == GameState.playing;
      overlayService.showHelp();
      if (_helpWasPlaying) {
        pauseEngine();
      }
    }
  }

  /// Handles player damage and checks for game over.
  void hitPlayer() {
    if (stateMachine.state != GameState.playing) {
      return;
    }
    player.flashDamage();
    if (scoreService.hitPlayer()) {
      stateMachine.gameOver();
    }
  }

  /// Adds [value] to the current score.
  void addScore(int value) => scoreService.addScore(value);

  /// Adds [value] to the current mineral count.
  void addMinerals(int value) => scoreService.addMinerals(value);

  /// Pauses the game and shows the pause overlay.
  void pauseGame() => stateMachine.pauseGame();

  /// Resumes the game from a paused state.
  void resumeGame() => stateMachine.resumeGame();

  /// Returns to the main menu without restarting the session.
  void returnToMenu() => stateMachine.returnToMenu();

  /// Starts a new game session.
  void startGame() => stateMachine.startGame();

  /// Clears the saved high score.
  Future<void> resetHighScore() => scoreService.resetHighScore();

  /// Transitions to the game over state.
  void gameOver() => stateMachine.gameOver();

  /// Toggles debug rendering and FPS overlay.
  void toggleDebug() {
    debugMode = !debugMode;

    // Propagate the new debug mode to all existing components so built-in
    // debug visuals like hitboxes update immediately.
    for (final child in children) {
      _applyDebugMode(child, debugMode);
    }

    if (debugMode) {
      if (_fpsText != null && !_fpsText!.isMounted) {
        add(_fpsText!);
      }
    } else {
      _fpsText?.removeFromParent();
    }
  }

  void _applyDebugMode(Component component, bool enabled) {
    component.debugMode = enabled;
    for (final child in component.children) {
      _applyDebugMode(child, enabled);
    }
  }

  /// Toggles rendering of the player's auto-aim radius.
  void toggleAutoAimRadius() {
    player.toggleAutoAimRadius();
  }

  void _onStart() {
    scoreService.reset();
    for (final enemy in enemies.toList()) {
      enemy.removeFromParent();
    }
    for (final asteroid in asteroids.toList()) {
      asteroid.removeFromParent();
    }
    children.whereType<BulletComponent>().forEach((b) => b.removeFromParent());
    if (!player.isMounted) {
      add(player);
      camera.follow(player);
    }
    player.setSprite(selectedPlayerSprite);
    player.reset();
    enemySpawner
      ..stop()
      ..start();
    asteroidSpawner
      ..stop()
      ..start();
    resumeEngine();
  }

  void _onGameOver() {
    enemySpawner.stop();
    asteroidSpawner.stop();
    scoreService.updateHighScoreIfNeeded();
    pauseEngine();
  }

  void _onMenu() {
    enemySpawner.stop();
    asteroidSpawner.stop();
    pauseEngine();
  }

  void _registerShortcuts() {
    keyDispatcher.register(LogicalKeyboardKey.escape, onDown: () {
      if (stateMachine.state == GameState.playing) {
        stateMachine.pauseGame();
      } else if (stateMachine.state == GameState.paused) {
        stateMachine.resumeGame();
      } else if (stateMachine.state == GameState.gameOver) {
        stateMachine.returnToMenu();
      }
    });

    keyDispatcher.register(LogicalKeyboardKey.keyP, onDown: () {
      if (stateMachine.state == GameState.playing) {
        stateMachine.pauseGame();
      } else if (stateMachine.state == GameState.paused) {
        stateMachine.resumeGame();
      }
    });

    keyDispatcher.register(
      LogicalKeyboardKey.keyM,
      onDown: audioService.toggleMute,
    );

    keyDispatcher.register(LogicalKeyboardKey.enter, onDown: () {
      if (stateMachine.state == GameState.menu ||
          stateMachine.state == GameState.gameOver) {
        stateMachine.startGame();
      }
    });

    keyDispatcher.register(LogicalKeyboardKey.keyR, onDown: () {
      if (stateMachine.state == GameState.gameOver ||
          stateMachine.state == GameState.playing ||
          stateMachine.state == GameState.paused) {
        stateMachine.startGame();
      }
    });

    keyDispatcher.register(LogicalKeyboardKey.keyQ, onDown: () {
      if (stateMachine.state == GameState.paused ||
          stateMachine.state == GameState.gameOver) {
        stateMachine.returnToMenu();
      }
    });

    keyDispatcher.register(
      LogicalKeyboardKey.keyH,
      onDown: toggleHelp,
    );

    keyDispatcher.register(
      LogicalKeyboardKey.keyU,
      onDown: toggleUpgrades,
    );

    keyDispatcher.register(
      LogicalKeyboardKey.f1,
      onDown: toggleDebug,
    );
  }
}
