import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'assets.dart';
import 'game/space_game.dart';
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
import 'services/theme_service.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Assets.load();
  final storage = await StorageService.create();
  final audio = await AudioService.create(storage);
  final settings = SettingsService();
  final theme = ThemeService();
  final focusNode = FocusNode();
  final game = SpaceGame(
    storageService: storage,
    audioService: audio,
    themeService: theme,
    settingsService: settings,
    focusNode: focusNode,
  );
  GameText.attachTextScale(settings.textScale);
  runApp(
    AnimatedBuilder(
      animation: theme,
      builder: (context, _) => MaterialApp(
        theme: theme.lightTheme,
        darkTheme: theme.darkTheme,
        themeMode: theme.themeMode,
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
