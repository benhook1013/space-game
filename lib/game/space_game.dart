import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter/widgets.dart' show FocusNode;
import 'package:flutter/material.dart' show ColorScheme, Colors;

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
import '../services/upgrade_service.dart';
import '../services/settings_service.dart';
import '../theme/game_theme.dart';
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
    ValueNotifier<ColorScheme>? colorScheme,
    ValueNotifier<GameColors>? gameColors,
    SettingsService? settingsService,
    FocusNode? focusNode,
  })  : colorScheme = colorScheme ??
            ValueNotifier(ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        gameColors = gameColors ?? ValueNotifier(GameColors.light),
        settingsService = settingsService ?? SettingsService(),
        focusNode = focusNode ?? FocusNode(),
        scoreService = ScoreService(storageService: storageService) {
    debugMode = kDebugMode;
    pools = createPoolManager();
    targetingService = TargetingService(eventBus);
    upgradeService = UpgradeService(scoreService: scoreService);
  }

  /// Handles persistence for the high score.
  final StorageService storageService;

  /// Plays sound effects and handles the mute toggle.
  final AudioService audioService;

  /// Provides runtime-adjustable UI settings.
  final SettingsService settingsService;

  /// Active colour scheme shared with Flutter widgets.
  final ValueNotifier<ColorScheme> colorScheme;

  /// Game-specific colours from [GameColors] extension.
  final ValueNotifier<GameColors> gameColors;

  /// Focus node used to capture keyboard input.
  final FocusNode focusNode;

  final ScoreService scoreService;
  late final OverlayService overlayService;
  late final GameStateMachine stateMachine;

  late final KeyDispatcher keyDispatcher;
  late PlayerComponent player;
  MiningLaserComponent? miningLaser;
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

  late void Function() _updateFireButtonColors;
  late void Function() _updateJoystickColors;

  ValueNotifier<int> get score => scoreService.score;
  ValueNotifier<int> get highScore => scoreService.highScore;
  ValueNotifier<int> get minerals => scoreService.minerals;
  ValueNotifier<int> get health => scoreService.health;
  late final UpgradeService upgradeService;

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

    joystick = _buildJoystick();
    await add(joystick);
    void updateJoystickColors() {
      (joystick.knob as CircleComponent).paint.color =
          colorScheme.value.primary;
      (joystick.background as CircleComponent).paint.color =
          colorScheme.value.primary.withValues(alpha: 0.4);
    }

    updateJoystickColors();
    _updateJoystickColors = updateJoystickColors;
    colorScheme.addListener(_updateJoystickColors);

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
    camera.add(
      BoundedPositionBehavior(
        bounds: Rectangle.fromLTWH(
          0,
          0,
          Constants.worldSize.x,
          Constants.worldSize.y,
        ),
        target: camera.viewfinder,
      ),
    );
    final laser = MiningLaserComponent(player: player);
    miningLaser = laser;
    await add(laser);

    final upButton = CircleComponent(
      radius: 30 * settingsService.hudButtonScale.value,
      paint: Paint(),
    );
    final downButton = CircleComponent(
      radius: 30 * settingsService.hudButtonScale.value,
      paint: Paint(),
    );
    fireButton = HudButtonComponent(
      button: upButton,
      buttonDown: downButton,
      anchor: Anchor.bottomRight,
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: player.startShooting,
      onReleased: player.stopShooting,
      onCancelled: player.stopShooting,
    );
    await add(fireButton);
    void updateFireButtonColors() {
      upButton.paint.color = colorScheme.value.primary.withValues(alpha: 0.4);
      downButton.paint.color = colorScheme.value.primary;
    }

    updateFireButtonColors();
    _updateFireButtonColors = updateFireButtonColors;
    colorScheme.addListener(_updateFireButtonColors);

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
      pauseGame: pauseGame,
      resumeGame: resumeGame,
      startGame: startGame,
      toggleHelp: toggleHelp,
      toggleUpgrades: toggleUpgrades,
      toggleDebug: toggleDebug,
    );
    stateMachine.returnToMenu();

    settingsService.joystickScale.addListener(_updateJoystickScale);
    settingsService.hudButtonScale.addListener(_updateHudButtonScale);
  }

  @override
  void onRemove() {
    colorScheme
      ..removeListener(_updateFireButtonColors)
      ..removeListener(_updateJoystickColors);
    super.onRemove();
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
      miningLaser?.stopSound();
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
        miningLaser?.stopSound();
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
  void pauseGame() {
    stateMachine.pauseGame();
    if (settingsService.muteOnPause.value) {
      miningLaser?.stopSound();
    } else {
      audioService.setMasterVolume(Constants.pausedAudioVolumeFactor);
    }
  }

  /// Resumes the game from a paused state.
  void resumeGame() {
    stateMachine.resumeGame();
    audioService.setMasterVolume(1);
    focusGame();
  }

  /// Returns to the main menu without restarting the session.
  void returnToMenu() => stateMachine.returnToMenu();

  /// Starts a new game session.
  void startGame() {
    audioService.setMasterVolume(1);
    stateMachine.startGame();
  }

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

  JoystickComponent _buildJoystick() {
    final scale = settingsService.joystickScale.value;
    final scheme = colorScheme.value;
    return JoystickComponent(
      knob: CircleComponent(
        radius: 20 * scale,
        paint: Paint()..color = scheme.primary,
      ),
      background: CircleComponent(
        radius: 50 * scale,
        paint: Paint()..color = scheme.primary.withValues(alpha: 0.4),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
  }

  void _updateJoystickScale() {
    final oldJoystick = joystick;
    final newJoystick = _buildJoystick();
    joystick = newJoystick;
    add(newJoystick);
    _updateJoystickColors();
    oldJoystick.removeFromParent();
  }

  void _updateHudButtonScale() {
    final scale = settingsService.hudButtonScale.value;
    (fireButton.button as CircleComponent).radius = 30 * scale;
    (fireButton.buttonDown as CircleComponent).radius = 30 * scale;
  }

  /// Requests keyboard focus for the surrounding [GameWidget].
  void focusGame() => focusNode.requestFocus();
}
