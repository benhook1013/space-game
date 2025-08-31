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
import 'services/storage_service.dart';
import 'services/audio_service.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Assets.load();
  final storage = await StorageService.create();
  final audio = await AudioService.create(storage);
  final focusNode = FocusNode();
  final game = SpaceGame(
    storageService: storage,
    audioService: audio,
    focusNode: focusNode,
  );
  runApp(
    MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            side: BorderSide(color: Colors.grey.shade500, width: 2),
          ),
        ),
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
          PauseOverlay.id: (context, SpaceGame game) =>
              PauseOverlay(game: game),
          GameOverOverlay.id: (context, SpaceGame game) =>
              GameOverOverlay(game: game),
          HelpOverlay.id: (context, SpaceGame game) => HelpOverlay(game: game),
          UpgradesOverlay.id: (context, SpaceGame game) =>
              UpgradesOverlay(game: game),
        },
      ),
    ),
  );
}
