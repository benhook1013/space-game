import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'assets.dart';
import 'game/space_game.dart';
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

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Assets.load();
  final storage = await StorageService.create();
  final audio = await AudioService.create(storage);
  final settings = SettingsService();
  final focusNode = FocusNode();

  final lightScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
  final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple, brightness: Brightness.dark);
  final colorScheme = ValueNotifier<ColorScheme>(lightScheme);
  final gameColors = ValueNotifier<GameColors>(GameColors.light);

  settings.themeMode.addListener(() {
    if (settings.themeMode.value == ThemeMode.dark) {
      colorScheme.value = darkScheme;
      gameColors.value = GameColors.dark;
    } else {
      colorScheme.value = lightScheme;
      gameColors.value = GameColors.light;
    }
  });

  final game = SpaceGame(
    storageService: storage,
    audioService: audio,
    settingsService: settings,
    focusNode: focusNode,
    colorScheme: colorScheme,
    gameColors: gameColors,
  );

  GameText.attachTextScale(settings.textScale);

  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: settings.themeMode,
      builder: (context, mode, _) => MaterialApp(
        theme: ThemeData(
          colorScheme: lightScheme,
          useMaterial3: true,
          extensions: const [GameColors.light],
        ),
        darkTheme: ThemeData(
          colorScheme: darkScheme,
          useMaterial3: true,
          extensions: const [GameColors.dark],
        ),
        themeMode: mode,
        home: GameWidget<SpaceGame>(
          game: game,
          focusNode: focusNode,
          // Automatically request keyboard focus so web players can use WASD
          // without tapping the canvas first.
          autofocus: true,
          overlayBuilderMap: {
            MenuOverlay.id: (context, SpaceGame game) =>
                MenuOverlay(game: game),
            HudOverlay.id: (context, SpaceGame game) => HudOverlay(game: game),
            PauseOverlay.id: (context, SpaceGame game) => const PauseOverlay(),
            GameOverOverlay.id: (context, SpaceGame game) =>
                GameOverOverlay(game: game),
            HelpOverlay.id: (context, SpaceGame game) =>
                HelpOverlay(game: game),
            UpgradesOverlay.id: (context, SpaceGame game) =>
                UpgradesOverlay(game: game),
            SettingsOverlay.id: (context, SpaceGame game) =>
                SettingsOverlay(game: game),
          },
        ),
      ),
    ),
  );
}
