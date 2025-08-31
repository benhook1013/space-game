import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'game_text.dart';
import 'overlay_widgets.dart';

/// Overlay shown when the game is paused.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  /// Reference to the running game.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'pauseOverlay';

  @override
  Widget build(BuildContext context) {
    return OverlayLayout(
      builder: (context, spacing, iconSize) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameText(
              'Paused',
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
            ),
            SizedBox(height: spacing),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  // Mirrors the Escape and P keyboard shortcuts.
                  onPressed: game.resumeGame,
                  child: const GameText(
                    'Resume',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: spacing),
                ElevatedButton(
                  // Mirrors the R keyboard shortcut.
                  onPressed: game.startGame,
                  child: const GameText(
                    'Restart',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: spacing),
                ElevatedButton(
                  // Mirrors the Q keyboard shortcut.
                  onPressed: game.returnToMenu,
                  child: const GameText(
                    'Menu',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: spacing),
                HelpButton(game: game),
                SizedBox(width: spacing),
                MuteButton(game: game, iconSize: iconSize),
              ],
            ),
          ],
        );
      },
    );
  }
}
