import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show FocusNode;
import 'package:flutter/material.dart' show ColorScheme, Colors;

import '../assets.dart';
import '../components/player.dart';
import '../components/mining_laser.dart';
import '../components/enemy_spawner.dart';
import '../components/asteroid_spawner.dart';
import '../game/key_dispatcher.dart';
import '../game/game_state_machine.dart';
import '../services/score_service.dart';
import '../services/overlay_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/asset_lifecycle_service.dart';
import '../services/targeting_service.dart';
import '../services/upgrade_service.dart';
import '../services/settings_service.dart';
import '../theme/game_theme.dart';
import 'event_bus.dart';
import 'pool_manager.dart';
import 'lifecycle_manager.dart';
import 'shortcut_manager.dart' as game_shortcuts;
import 'starfield_manager.dart';
import 'control_manager.dart';
import 'debug_controller.dart';
import 'ui_controller.dart';
import 'health_regen_system.dart';
import 'game_services.dart';
import 'world_builder.dart';
import 'overlay_coordinator.dart';
import 'game_flow.dart';

/// Root Flame game handling the core loop.
///
/// [HasKeyboardHandlerComponents] already exposes [KeyboardEvents] and
/// propagates key presses to child components like the player. Mixing in the
/// standalone [KeyboardEvents] here would prevent that propagation, so it is
/// intentionally omitted.
class SpaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection, DebugController {
  SpaceGame({
    required this.storageService,
    required this.audioService,
    ColorScheme? colorScheme,
    GameColors? gameColors,
    SettingsService? settingsService,
    FocusNode? focusNode,
  })  : selectedPlayerIndex = ValueNotifier<int>(
          storageService
              .getPlayerSpriteIndex()
              .clamp(0, Assets.players.length - 1),
        ),
        colorScheme =
            colorScheme ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        gameColors = gameColors ?? GameColors.dark,
        settingsService = settingsService ?? SettingsService(),
        focusNode = focusNode ?? FocusNode(),
        scoreService = ScoreService(storageService: storageService) {
    initGameServices(this);
    gameFlow = GameFlow(this);
  }

  /// Handles persistence for the high score.
  final StorageService storageService;

  /// Plays sound effects and handles the mute toggle.
  final AudioService audioService;

  /// Provides runtime-adjustable UI settings.
  final SettingsService settingsService;

  /// Active colour scheme shared with Flutter widgets.
  final ColorScheme colorScheme;

  /// Game-specific colours from [GameColors] extension.
  final GameColors gameColors;

  /// Focus node used to capture keyboard input.
  final FocusNode focusNode;

  final ScoreService scoreService;

  /// Provides asset loading and pause/resume logic.
  late final AssetLifecycleService assetLifecycle;

  late final OverlayCoordinator overlayCoordinator;
  late OverlayService overlayService;
  late GameStateMachine stateMachine;
  late LifecycleManager lifecycle;
  late game_shortcuts.ShortcutManager shortcuts;
  late UiController ui;

  late final KeyDispatcher keyDispatcher;
  late PlayerComponent player;
  MiningLaserComponent? miningLaser;
  late final ControlManager controlManager;
  JoystickComponent get joystick => controlManager.joystick;
  HudButtonComponent get fireButton => controlManager.fireButton!;
  late final EnemySpawner enemySpawner;
  late final AsteroidSpawner asteroidSpawner;
  late final PoolManager pools;
  final GameEventBus eventBus = GameEventBus();
  late final TargetingService targetingService;
  late final StarfieldManager starfieldManager;
  late final HealthRegenSystem healthRegen;
  FpsTextComponent? _fpsText;

  late final GameFlow gameFlow;

  /// Whether [onLoad] has finished and late fields are initialised.
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  ValueNotifier<int> get score => scoreService.score;
  ValueNotifier<int> get highScore => scoreService.highScore;
  ValueNotifier<int> get minerals => scoreService.minerals;
  ValueNotifier<int> get health => scoreService.health;
  late final UpgradeService upgradeService;

  /// Selected player sprite index for menu selection.
  final ValueNotifier<int> selectedPlayerIndex;

  String get selectedPlayerSprite => Assets.players[selectedPlayerIndex.value];

  void selectPlayer(int index) {
    final clamped = index.clamp(0, Assets.players.length - 1);
    selectedPlayerIndex.value = clamped;
    storageService.setPlayerSpriteIndex(clamped);
  }

  /// Reports progress while remaining assets load.
  ValueNotifier<double> get assetLoadProgress =>
      assetLifecycle.assetLoadProgress;

  @override
  Future<void> onLoad() async {
    if (kDebugMode) {
      _fpsText = FpsTextComponent(position: Vector2.all(10));
      await add(_fpsText!);
    }

    keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);

    await controlManager.init();

    await starfieldManager.init();

    await buildWorld(this);
    overlayCoordinator = OverlayCoordinator(game: this);
    await overlayCoordinator.init();
    overlayService = overlayCoordinator.overlayService;
    lifecycle = overlayCoordinator.lifecycle;
    stateMachine = overlayCoordinator.stateMachine;
    ui = overlayCoordinator.ui;
    shortcuts = overlayCoordinator.shortcuts;
    _isLoaded = true;
  }

  @protected
  PoolManager createPoolManager() => PoolManager(events: eventBus);

  /// Handles player damage and checks for game over.
  void hitPlayer() => gameFlow.hitPlayer();

  /// Adds [value] to the current score.
  void addScore(int value) => gameFlow.addScore(value);

  /// Adds [value] to the current mineral count.
  void addMinerals(int value) => gameFlow.addMinerals(value);

  /// Resets the shield regeneration timer.
  void resetHealthRegenTimer() => gameFlow.resetHealthRegenTimer();

  /// Pauses the game and shows the `PAUSED` overlay.
  void pauseGame() => gameFlow.pauseGame();

  /// Resumes the game from a paused state.
  void resumeGame() => gameFlow.resumeGame();

  /// Returns to the main menu without restarting the session.
  void returnToMenu() => gameFlow.returnToMenu();

  /// Begins loading assets needed for gameplay.
  ///
  /// Safe to call multiple times; subsequent invocations are ignored.
  void startLoadingAssets() => gameFlow.startLoadingAssets();

  /// Starts a new game session.
  Future<void> startGame() => gameFlow.startGame();

  /// Clears the saved high score.
  ///
  /// Returns `true` if the score was removed from storage.
  Future<bool> resetHighScore() => gameFlow.resetHighScore();

  /// Transitions to the game over state.
  void gameOver() => gameFlow.gameOver();

  @override
  void onDebugModeChanged(bool enabled) {
    // Ensure pooled components also reflect the new debug mode so reused
    // instances don't retain stale debug flags.
    pools.applyDebugMode(enabled);

    // Outline starfield tiles when debug visuals are enabled.
    starfieldManager.updateDebug(enabled);

    if (enabled) {
      if (_fpsText != null && !_fpsText!.isMounted) {
        add(_fpsText!);
      }
    } else {
      _fpsText?.removeFromParent();
    }
  }

  /// Ensures the camera stays centred on the player.
  @override
  void update(double dt) {
    final shouldFreeze =
        _isLoaded && (stateMachine.isPaused || stateMachine.isUpgrades);
    final effectiveDt = shouldFreeze ? 0.0 : dt;
    super.update(effectiveDt);

    if (_isLoaded) {
      healthRegen.update(effectiveDt, stateMachine.isPlaying);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    camera.viewfinder.anchor = Anchor.center;
  }

  @override
  void onRemove() {
    settingsService.dispose();
    scoreService.dispose();
    upgradeService.dispose();
    targetingService.dispose();
    stateMachine.dispose();
    controlManager.dispose();
    audioService.dispose();
    assetLifecycle.dispose();
    starfieldManager.dispose();
    pools.dispose();
    super.onRemove();
    // Dispose the event bus after children are removed so they can emit
    // removal events without errors.
    unawaited(eventBus.dispose());
  }

  /// Requests keyboard focus for the surrounding [GameWidget].
  void focusGame() => focusNode.requestFocus();
}
