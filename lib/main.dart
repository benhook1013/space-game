import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'assets.dart';
import 'game/space_game.dart';
import 'game/game_state.dart';
import 'theme/game_theme.dart';
import 'ui/game_over_overlay.dart';
import 'ui/hud_overlay.dart';
import 'ui/menu_overlay.dart';
import 'ui/pause_overlay.dart';
import 'ui/help_overlay.dart';
import 'ui/upgrades_overlay.dart';
import 'ui/settings_overlay.dart';
import 'ui/game_text.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';
import 'util/interaction.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Assets.loadEssential();
  final storage = await StorageService.create();
  final audio = await AudioService.create(storage);
  final settings = SettingsService();
  final focusNode = FocusNode();

  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  );
  const gameColors = GameColors.dark;

  final game = SpaceGame(
    storageService: storage,
    audioService: audio,
    settingsService: settings,
    focusNode: focusNode,
    colorScheme: colorScheme,
    gameColors: gameColors,
  );

  onFirstUserInteraction(game.startLoadingAssets);

  // Pause the game and silence audio when the app is not visible.
  final lifecycleObserver = _AppLifecycleObserver(game);
  WidgetsBinding.instance.addObserver(lifecycleObserver);

  GameText.attachTextScale(settings.textScale);

  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        extensions: const [GameColors.dark],
      ),
      home: GameWidget<SpaceGame>(
        game: game,
        focusNode: focusNode,
        // Automatically request keyboard focus so web players can use WASD
        // without tapping the canvas first.
        autofocus: true,
        overlayBuilderMap: {
          MenuOverlay.id: (context, SpaceGame game) => MenuOverlay(game: game),
          HudOverlay.id: (context, SpaceGame game) => HudOverlay(game: game),
          PauseOverlay.id: (context, SpaceGame game) => const PauseOverlay(),
          GameOverOverlay.id: (context, SpaceGame game) =>
              GameOverOverlay(game: game),
          HelpOverlay.id: (context, SpaceGame game) => HelpOverlay(game: game),
          UpgradesOverlay.id: (context, SpaceGame game) =>
              UpgradesOverlay(game: game),
          SettingsOverlay.id: (context, SpaceGame game) =>
              SettingsOverlay(game: game),
        },
      ),
    ),
  );
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  _AppLifecycleObserver(this.game);

  final SpaceGame game;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      game.pauseEngine();
      final laser = game.miningLaser;
      if (laser != null && laser.isMounted) {
        laser.stopSound();
      }
      game.audioService.stopAll();
    } else if (state == AppLifecycleState.resumed) {
      if (game.isLoaded && game.stateMachine.state == GameState.playing) {
        game.resumeEngine();
        game.focusGame();
      }
    }
  }
}
