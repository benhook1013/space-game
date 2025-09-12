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
import '../components/explosion.dart';
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
import '../ui/help_overlay.dart';
import 'event_bus.dart';
import 'pool_manager.dart';
import 'lifecycle_manager.dart';
import 'shortcut_manager.dart' as game_shortcuts;
import 'starfield_manager.dart';
import 'control_manager.dart';
import 'debug_controller.dart';
import 'ui_controller.dart';
import 'health_regen_system.dart';

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
    _initServices();
  }

  void _initServices() {
    final storedIndex = storageService.getPlayerSpriteIndex();
    if (storedIndex != selectedPlayerIndex.value) {
      unawaited(storageService.setPlayerSpriteIndex(selectedPlayerIndex.value));
    }
    settingsService.attachStorage(storageService);
    debugMode = kDebugMode;
    pools = createPoolManager();
    targetingService = TargetingService(eventBus);
    upgradeService = UpgradeService(
      scoreService: scoreService,
      storageService: storageService,
      settingsService: settingsService,
    );
    healthRegen = HealthRegenSystem(
      scoreService: scoreService,
      upgradeService: upgradeService,
    );
    starfieldManager = StarfieldManager(
      game: this,
      settings: settingsService,
      debugMode: debugMode,
    );
    controlManager = ControlManager(
      game: this,
      settings: settingsService,
      colorScheme: colorScheme,
    );
    assetLifecycle = AssetLifecycleService(
      game: this,
      audioService: audioService,
    );
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

  late final OverlayService overlayService;
  late final GameStateMachine stateMachine;

  late final KeyDispatcher keyDispatcher;
  late PlayerComponent player;
  MiningLaserComponent? miningLaser;
  late final ControlManager controlManager;
  JoystickComponent get joystick => controlManager.joystick;
  HudButtonComponent get fireButton => controlManager.fireButton!;
  late final EnemySpawner enemySpawner;
  late final AsteroidSpawner asteroidSpawner;
  late final PoolManager pools;
  late final LifecycleManager lifecycle;
  late final game_shortcuts.ShortcutManager shortcuts;
  final GameEventBus eventBus = GameEventBus();
  late final TargetingService targetingService;
  late final StarfieldManager starfieldManager;
  late final HealthRegenSystem healthRegen;
  late final UiController ui;
  FpsTextComponent? _fpsText;

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

    await _initWorld();
    await _initOverlays();
    _isLoaded = true;
  }

  Future<void> _initWorld() async {
    player = PlayerComponent(
      joystick: controlManager.joystick,
      keyDispatcher: keyDispatcher,
      spritePath: selectedPlayerSprite,
    );
    await add(player);
    camera.follow(player, snap: true);
    final laser = MiningLaserComponent(player: player);
    miningLaser = laser;
    await add(laser);

    await controlManager.attachPlayer(player);

    enemySpawner = EnemySpawner();
    asteroidSpawner = AsteroidSpawner();
    await add(enemySpawner);
    await add(asteroidSpawner);
  }

  Future<void> _initOverlays() async {
    overlayService = OverlayService(this);
    lifecycle = LifecycleManager(this);
    stateMachine = GameStateMachine(
      overlays: overlayService,
      onStart: lifecycle.onStart,
      // Keep the engine running when paused so HUD tweaks render live.
      onPause: () {},
      onResume: () {},
      onGameOver: lifecycle.onGameOver,
      onMenu: lifecycle.onMenu,
      onEnterUpgrades: () {
        pauseEngine();
        miningLaser?.stopSound();
      },
      onExitUpgrades: () {
        resumeEngine();
        focusGame();
      },
    );

    ui = UiController(
      overlayService: overlayService,
      stateMachine: stateMachine,
      player: () => player,
      miningLaser: () => miningLaser,
      pauseEngine: pauseEngine,
      resumeEngine: resumeEngine,
      focusGame: focusGame,
    );

    shortcuts = game_shortcuts.ShortcutManager(
      keyDispatcher: keyDispatcher,
      stateMachine: stateMachine,
      audioService: audioService,
      pauseGame: pauseGame,
      resumeGame: resumeGame,
      startGame: () => startGame(),
      toggleHelp: ui.toggleHelp,
      toggleUpgrades: ui.toggleUpgrades,
      toggleDebug: toggleDebug,
      toggleMinimap: ui.toggleMinimap,
      toggleRangeRings: ui.toggleRangeRings,
      toggleSettings: ui.toggleSettings,
      returnToMenu: returnToMenu,
      isHelpVisible: () => overlays.isActive(HelpOverlay.id),
    );
    stateMachine.returnToMenu();
  }

  @protected
  PoolManager createPoolManager() => PoolManager(events: eventBus);

  /// Handles player damage and checks for game over.
  void hitPlayer() {
    if (!stateMachine.isPlaying) {
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

  /// Resets the shield regeneration timer.
  void resetHealthRegenTimer() => healthRegen.reset();

  /// Pauses the game and shows the `PAUSED` overlay.
  void pauseGame() => assetLifecycle.pauseGame();

  /// Resumes the game from a paused state.
  void resumeGame() => assetLifecycle.resumeGame();

  /// Returns to the main menu without restarting the session.
  void returnToMenu() => stateMachine.returnToMenu();

  /// Begins loading assets needed for gameplay.
  ///
  /// Safe to call multiple times; subsequent invocations are ignored.
  void startLoadingAssets() => assetLifecycle.startLoadingAssets();

  /// Starts a new game session.
  Future<void> startGame() => assetLifecycle.startGame();

  /// Clears the saved high score.
  ///
  /// Returns `true` if the score was removed from storage.
  Future<bool> resetHighScore() => scoreService.resetHighScore();

  /// Transitions to the game over state.
  void gameOver() => stateMachine.gameOver();

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
