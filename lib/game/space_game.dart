import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
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
import '../theme/star_palette.dart';
import '../ui/help_overlay.dart';
import '../ui/settings_overlay.dart';
import 'event_bus.dart';
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
    final storedIndex = storageService.getPlayerSpriteIndex();
    if (storedIndex != selectedPlayerIndex.value) {
      unawaited(storageService.setPlayerSpriteIndex(selectedPlayerIndex.value));
    }
    this.settingsService.attachStorage(storageService);
    debugMode = kDebugMode;
    pools = createPoolManager();
    targetingService = TargetingService(eventBus);
    upgradeService = UpgradeService(
      scoreService: scoreService,
      storageService: storageService,
      settingsService: this.settingsService,
    );
    _storedVolume = audioService.masterVolume;
    audioService.volume.addListener(() {
      if (!_suppressVolumeSave) {
        _storedVolume = audioService.masterVolume;
      }
    });
  }

  /// Handles persistence for the high score.
  final StorageService storageService;

  /// Plays sound effects and handles the mute toggle.
  final AudioService audioService;

  double _storedVolume = 1;
  bool _suppressVolumeSave = false;

  double _healthRegenTimer = 0;

  /// Provides runtime-adjustable UI settings.
  final SettingsService settingsService;

  /// Active colour scheme shared with Flutter widgets.
  final ColorScheme colorScheme;

  /// Game-specific colours from [GameColors] extension.
  final GameColors gameColors;

  /// Focus node used to capture keyboard input.
  final FocusNode focusNode;

  final ScoreService scoreService;

  /// Reports progress while remaining assets load.
  final ValueNotifier<double> assetLoadProgress = ValueNotifier<double>(0);
  Future<void>? _assetLoadFuture;

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
  int _starfieldRebuildId = 0;
  FpsTextComponent? _fpsText;
  bool _playerInitialized = false;
  final ValueNotifier<bool> showMinimap = ValueNotifier<bool>(true);

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

  void toggleMinimap() {
    showMinimap.value = !showMinimap.value;
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

    final palette = settingsService.starfieldPalette.value.colors;
    _starfield = await StarfieldComponent(
      debugDrawTiles: debugMode,
      layers: [
        StarfieldLayerConfig(
            parallax: 0.2, density: 0.15, twinkleSpeed: 0.5, palette: palette),
        StarfieldLayerConfig(
            parallax: 0.6, density: 0.3, twinkleSpeed: 0.8, palette: palette),
        StarfieldLayerConfig(
            parallax: 1.0, density: 0.5, twinkleSpeed: 1, palette: palette),
      ],
      tileSize: settingsService.starfieldTileSize.value,
      densityMultiplier: settingsService.starfieldDensity.value,
      brightnessMultiplier: settingsService.starfieldBrightness.value,
      gamma: settingsService.starfieldGamma.value,
    );
    await add(_starfield!);
    settingsService.starfieldTileSize.addListener(_rebuildStarfield);
    settingsService.starfieldDensity.addListener(_rebuildStarfield);
    settingsService.starfieldBrightness.addListener(_rebuildStarfield);
    settingsService.starfieldGamma.addListener(_rebuildStarfield);
    settingsService.starfieldPalette.addListener(_rebuildStarfield);

    player = PlayerComponent(
      joystick: joystick,
      keyDispatcher: keyDispatcher,
      spritePath: selectedPlayerSprite,
    );
    await add(player);
    _playerInitialized = true;
    camera.follow(player, snap: true);
    final laser = MiningLaserComponent(player: player);
    miningLaser = laser;
    await add(laser);

    fireButton = _buildFireButton(settingsService.joystickScale.value);
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

    shortcuts = game_shortcuts.ShortcutManager(
      keyDispatcher: keyDispatcher,
      stateMachine: stateMachine,
      audioService: audioService,
      pauseGame: pauseGame,
      resumeGame: resumeGame,
      startGame: () => startGame(),
      toggleHelp: toggleHelp,
      toggleUpgrades: toggleUpgrades,
      toggleDebug: toggleDebug,
      toggleMinimap: toggleMinimap,
      toggleRangeRings: toggleRangeRings,
      toggleSettings: toggleSettings,
      returnToMenu: returnToMenu,
      isHelpVisible: () => overlays.isActive(HelpOverlay.id),
    );
    stateMachine.returnToMenu();

    settingsService.joystickScale.addListener(_updateJoystickScale);
    _isLoaded = true;
  }

  @protected
  PoolManager createPoolManager() => PoolManager(events: eventBus);

  /// Toggles the upgrades overlay and pauses/resumes the game.
  void toggleUpgrades() => stateMachine.toggleUpgrades();

  /// Toggles the help overlay and pauses/resumes if entering from gameplay.
  void toggleHelp() {
    if (overlays.isActive(HelpOverlay.id)) {
      overlayService.hideHelp();
      if (_helpWasPlaying) {
        resumeEngine();
        focusGame();
      }
    } else {
      _helpWasPlaying = stateMachine.isPlaying;
      overlayService.showHelp();
      if (_helpWasPlaying) {
        pauseEngine();
        miningLaser?.stopSound();
      }
    }
  }

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
  void resetHealthRegenTimer() => _healthRegenTimer = 0;

  /// Pauses the game and shows the `PAUSED` overlay.
  void pauseGame() {
    stateMachine.pauseGame();
    _storedVolume = audioService.masterVolume;
    _suppressVolumeSave = true;
    audioService.setMasterVolume(
      _storedVolume * Constants.pausedAudioVolumeFactor,
    );
    _suppressVolumeSave = false;
  }

  /// Resumes the game from a paused state.
  void resumeGame() {
    stateMachine.resumeGame();
    resumeEngine();
    _suppressVolumeSave = true;
    audioService.setMasterVolume(_storedVolume);
    _suppressVolumeSave = false;
    focusGame();
  }

  /// Returns to the main menu without restarting the session.
  void returnToMenu() => stateMachine.returnToMenu();

  /// Begins loading assets needed for gameplay.
  ///
  /// Safe to call multiple times; subsequent invocations are ignored.
  void startLoadingAssets() {
    _assetLoadFuture ??= Assets.loadRemaining(
      onProgress: (p) => assetLoadProgress.value = p,
    );
  }

  Future<void> _ensureAssetsLoaded() async {
    await (_assetLoadFuture ??= Assets.loadRemaining(
      onProgress: (p) => assetLoadProgress.value = p,
    ));
    assetLoadProgress.value = 1;
  }

  /// Starts a new game session.
  Future<void> startGame() async {
    await _ensureAssetsLoaded();
    _suppressVolumeSave = true;
    audioService.setMasterVolume(_storedVolume);
    _suppressVolumeSave = false;
    stateMachine.startGame();
  }

  /// Clears the saved high score.
  ///
  /// Returns `true` if the score was removed from storage.
  Future<bool> resetHighScore() => scoreService.resetHighScore();

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

    // Ensure pooled components also reflect the new debug mode so reused
    // instances don't retain stale debug flags.
    pools.applyDebugMode(debugMode);

    // Outline starfield tiles when debug visuals are enabled.
    _starfield?.debugDrawTiles = debugMode;

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

  /// Toggles rendering of the player's range rings.
  void toggleRangeRings() {
    player.toggleRangeRings();
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
    final scheme = colorScheme;
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
    )..anchor = Anchor.bottomLeft;
  }

  HudButtonComponent _buildFireButton(double scale) {
    final scheme = colorScheme;
    return HudButtonComponent(
      button: CircleComponent(
        radius: 30 * scale,
        paint: Paint()..color = scheme.primary.withValues(alpha: 0.4),
      ),
      buttonDown: CircleComponent(
        radius: 30 * scale,
        paint: Paint()..color = scheme.primary,
      ),
      anchor: Anchor.bottomRight,
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: player.startShooting,
      onReleased: player.stopShooting,
      onCancelled: player.stopShooting,
    )..size = Vector2.all(60 * scale);
  }

  void _updateJoystickScale() {
    final scale = settingsService.joystickScale.value;
    // Update the joystick in place to avoid flicker when scaling. Adjust the
    // knob and background radii so growth originates from the bottom-left
    // corner while keeping the knob centred.
    final bg = joystick.background as CircleComponent;
    final knob = joystick.knob as CircleComponent;
    bg
      ..radius = 50 * scale
      ..position = Vector2.zero();
    knob
      ..radius = 20 * scale
      ..position = Vector2.zero();
    // Update cached values so the hitbox matches the visual size.
    joystick
      ..size = Vector2.all(100 * scale)
      ..knobRadius = 20 * scale
      ..anchor = Anchor.bottomLeft
      ..position = Vector2(40, size.y - 40);
    joystick.onGameResize(size);

    // Scale the fire button to match the joystick and stay anchored
    // to the bottom-right corner.
    (fireButton.button as CircleComponent).radius = 30 * scale;
    (fireButton.buttonDown as CircleComponent).radius = 30 * scale;
    fireButton.size = Vector2.all(60 * scale);
    fireButton.anchor = Anchor.bottomRight;
    fireButton.onGameResize(size);
  }

  void _rebuildStarfield() {
    final tileSize = settingsService.starfieldTileSize.value;
    final density = settingsService.starfieldDensity.value;
    final brightness = settingsService.starfieldBrightness.value;
    final gamma = settingsService.starfieldGamma.value;
    final palette = settingsService.starfieldPalette.value.colors;
    _starfield?.removeFromParent();
    _starfield = null;
    final buildId = ++_starfieldRebuildId;
    unawaited(() async {
      final sf = await StarfieldComponent(
        debugDrawTiles: debugMode,
        layers: [
          StarfieldLayerConfig(
              parallax: 0.2, density: 0.3, twinkleSpeed: 0.5, palette: palette),
          StarfieldLayerConfig(
              parallax: 0.6, density: 0.6, twinkleSpeed: 0.8, palette: palette),
          StarfieldLayerConfig(
              parallax: 1.0, density: 1, twinkleSpeed: 1, palette: palette),
        ],
        tileSize: tileSize,
        densityMultiplier: density,
        brightnessMultiplier: brightness,
        gamma: gamma,
      );
      if (buildId != _starfieldRebuildId) {
        return;
      }
      _starfield = sf;
      await add(sf);
    }());
  }

  /// Ensures the camera stays centred on the player.
  @override
  void update(double dt) {
    final shouldFreeze =
        _isLoaded && (stateMachine.isPaused || stateMachine.isUpgrades);
    final effectiveDt = shouldFreeze ? 0.0 : dt;
    super.update(effectiveDt);

    if (_isLoaded &&
        stateMachine.isPlaying &&
        upgradeService.hasShieldRegen &&
        scoreService.health.value < Constants.playerMaxHealth) {
      _healthRegenTimer += effectiveDt;
      if (_healthRegenTimer >= Constants.playerHealthRegenInterval) {
        _healthRegenTimer = 0;
        scoreService.health.value =
            (scoreService.health.value + 1).clamp(0, Constants.playerMaxHealth);
      }
    } else {
      _healthRegenTimer = 0;
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
    audioService.dispose();
    pools.dispose();
    super.onRemove();
    // Dispose the event bus after children are removed so they can emit
    // removal events without errors.
    eventBus.dispose();
  }

  /// Requests keyboard focus for the surrounding [GameWidget].
  void focusGame() => focusNode.requestFocus();
}
