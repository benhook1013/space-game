import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'assets.dart';
import 'game/space_game.dart';
import 'ui/game_over_overlay.dart';
import 'ui/hud_overlay.dart';
import 'ui/menu_overlay.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Assets.load();
  final game = SpaceGame();
  runApp(
    MaterialApp(
      home: GameWidget<SpaceGame>(
        game: game,
        overlayBuilderMap: {
          MenuOverlay.id: (context, SpaceGame game) => MenuOverlay(game: game),
          HudOverlay.id: (context, SpaceGame game) => HudOverlay(game: game),
          GameOverOverlay.id: (context, SpaceGame game) =>
              GameOverOverlay(game: game),
        },
      ),
    ),
  );
}
