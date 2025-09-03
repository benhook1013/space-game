import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/widgets.dart' show FocusNode;

import '../assets.dart';
import '../components/player.dart';
import '../components/mining_laser.dart';
import '../components/enemy_spawner.dart';
import '../components/asteroid_spawner.dart';
import '../components/starfield.dart';
import '../components/explosion.dart';
import '../constants.dart';
import '../game/key_dispatcher.dart';
import '../game/game_state_machine.dart';
import '../services/score_service.dart';
import '../services/overlay_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/targeting_service.dart';
import '../services/settings_service.dart';
import '../ui/help_overlay.dart';
import '../ui/upgrades_overlay.dart';
import '../ui/settings_overlay.dart';
import 'event_bus.dart';
import 'game_state.dart';
import 'pool_manager.dart';
import 'lifecycle_manager.dart';
import 'shortcut_manager.dart' as game_shortcuts;

/// Root Flame game handling the core loop.
///
/// [HasKeyboardHandlerComponents] already exposes [KeyboardEvents] and
/// propagates key presses to child components like the player. Mixing in the
/// standalone [KeyboardEvents] here would prevent that propagation, so it is
/// intentionally omitted.
class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  SpaceGame({
    required this.storageService,
    required this.audioService,
    SettingsService? settingsService,
    FocusNode? focusNode,
  })  : settingsService = settingsService ?? SettingsService(),
        focusNode = focusNode ?? FocusNode(),
        scoreService = ScoreService(storageService: storageService) {
    debugMode = kDebugMode;
    pools = createPoolManager();
    targetingService = TargetingService(eventBus);
  }

  /// Handles persistence for the high score.
  final StorageService storageService;

  /// Plays sound effects and handles the mute toggle.
  final AudioService audioService;

  /// Provides runtime-adjustable UI settings.
  final SettingsService settingsService;

  /// Focus node used to capture keyboard input.
  final FocusNode focusNode;

  final ScoreService scoreService;
  late final OverlayService overlayService;
  late final GameStateMachine stateMachine;

  late final KeyDispatcher keyDispatcher;
  late PlayerComponent player;
  late MiningLaserComponent miningLaser;
  late JoystickComponent _joystick;
  JoystickComponent get joystick => _joystick;
  set joystick(JoystickComponent value) {
    _joystick = value;
    if (_playerInitialized) {
      player.setJoystick(value);
    }
  }

  late final HudButtonComponent fireButton;
  late final EnemySpawner enemySpawner;
  late final AsteroidSpawner asteroidSpawner;
  late final PoolManager pools;
  late final LifecycleManager lifecycle;
  late final game_shortcuts.ShortcutManager shortcuts;
  final GameEventBus eventBus = GameEventBus();
  late final TargetingService targetingService;
  StarfieldComponent? _starfield;
  FpsTextComponent? _fpsText;
  bool _playerInitialized = false;

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
        radius: 20 * settingsService.joystickScale.value,
        paint: Paint()..color = const Color(0xffffffff),
      ),
      background: CircleComponent(
        radius: 50 * settingsService.joystickScale.value,
        paint: Paint()..color = const Color(0x66ffffff),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    await add(joystick);

    _starfield = await StarfieldComponent();
    await add(_starfield!);

    player = PlayerComponent(
      joystick: joystick,
      keyDispatcher: keyDispatcher,
      spritePath: selectedPlayerSprite,
    );
    player.position = Constants.worldSize / 2;
    await add(player);
    _playerInitialized = true;
    camera.follow(player, snap: true);
    miningLaser = MiningLaserComponent(player: player);
    await add(miningLaser);

    fireButton = HudButtonComponent(
      button: CircleComponent(
        radius: 30 * settingsService.hudButtonScale.value,
        paint: Paint()..color = const Color(0x66ffffff),
      ),
      buttonDown: CircleComponent(
        radius: 30 * settingsService.hudButtonScale.value,
        paint: Paint()..color = const Color(0xffffffff),
      ),
      anchor: Anchor.bottomRight,
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: player.startShooting,
      onReleased: player.stopShooting,
    );
    await add(fireButton);

    enemySpawner = EnemySpawner();
    asteroidSpawner = AsteroidSpawner();
    await add(enemySpawner);
    await add(asteroidSpawner);

    overlayService = OverlayService(this);
    lifecycle = LifecycleManager(this);
    stateMachine = GameStateMachine(
      overlays: overlayService,
      onStart: lifecycle.onStart,
      onPause: pauseEngine,
      onResume: resumeEngine,
      onGameOver: lifecycle.onGameOver,
      onMenu: lifecycle.onMenu,
    );

    shortcuts = game_shortcuts.ShortcutManager(
      keyDispatcher: keyDispatcher,
      stateMachine: stateMachine,
      audioService: audioService,
      toggleHelp: toggleHelp,
      toggleUpgrades: toggleUpgrades,
      toggleDebug: toggleDebug,
    );
    stateMachine.returnToMenu();

    settingsService.joystickScale.addListener(_updateJoystickScale);
    settingsService.hudButtonScale.addListener(_updateHudButtonScale);
  }

  @protected
  PoolManager createPoolManager() => PoolManager(events: eventBus);

  /// Toggles the upgrades overlay and pauses/resumes the game.
  void toggleUpgrades() {
    if (overlays.isActive(UpgradesOverlay.id)) {
      overlayService.hideUpgrades();
      stateMachine.state = GameState.playing;
      resumeEngine();
      focusGame();
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
        focusGame();
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
      add(ExplosionComponent(position: player.position.clone()));
      audioService.playExplosion();
      player.removeFromParent();
      stateMachine.gameOver();
    }
  }

  /// Adds [value] to the current score.
  void addScore(int value) => scoreService.addScore(value);

  /// Adds [value] to the current mineral count.
  void addMinerals(int value) => scoreService.addMinerals(value);

  /// Pauses the game and shows the `PAUSED` overlay.
  void pauseGame() => stateMachine.pauseGame();

  /// Resumes the game from a paused state.
  void resumeGame() {
    stateMachine.resumeGame();
    focusGame();
  }

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

  /// Shows or hides the runtime settings overlay.
  void toggleSettings() {
    if (overlays.isActive(SettingsOverlay.id)) {
      overlayService.hideSettings();
    } else {
      overlayService.showSettings();
    }
  }

  void _updateJoystickScale() {
    final scale = settingsService.joystickScale.value;
    (joystick.knob as CircleComponent).radius = 20 * scale;
    (joystick.background as CircleComponent).radius = 50 * scale;
  }

  void _updateHudButtonScale() {
    final scale = settingsService.hudButtonScale.value;
    (fireButton.button as CircleComponent).radius = 30 * scale;
    (fireButton.buttonDown as CircleComponent).radius = 30 * scale;
  }

  /// Requests keyboard focus for the surrounding [GameWidget].
  void focusGame() => focusNode.requestFocus();
}
