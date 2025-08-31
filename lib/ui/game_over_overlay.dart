import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'game_text.dart';
import 'overlay_widgets.dart';

/// Overlay displayed when the player dies.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  /// Reference to the running game instance.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'gameOverOverlay';

  @override
  Widget build(BuildContext context) {
    return OverlayLayout(
      builder: (context, spacing, iconSize) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameText(
              'Game Over',
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
            ),
            SizedBox(height: spacing),
            ValueListenableBuilder<int>(
              valueListenable: game.score,
              builder: (context, value, _) => GameText(
                'Final Score: $value',
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: spacing),
            ValueListenableBuilder<int>(
              valueListenable: game.highScore,
              builder: (context, value, _) => GameText(
                'High Score: $value',
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: spacing),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  // Mirrors the Enter and R keyboard shortcuts.
                  onPressed: game.startGame,
                  child: const GameText(
                    'Restart',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: spacing),
                ElevatedButton(
                  // Mirrors the Q and Escape keyboard shortcuts.
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
