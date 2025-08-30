import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'game_text.dart';
import 'responsive.dart';

/// Overlay shown when the game is paused.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  /// Reference to the running game.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'pauseOverlay';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.biggest.shortestSide;
        final spacing = shortestSide * 0.02;
        final iconSize = responsiveIconSize(constraints);

        return Center(
          child: Column(
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
                  ElevatedButton(
                    // Mirrors the H keyboard shortcut.
                    onPressed: game.toggleHelp,
                    child: const GameText(
                      'Help',
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: spacing),
                  ValueListenableBuilder<bool>(
                    valueListenable: game.audioService.muted,
                    builder: (context, muted, _) => IconButton(
                      iconSize: iconSize,
                      icon: Icon(
                        muted ? Icons.volume_off : Icons.volume_up,
                        color: GameText.defaultColor,
                      ),
                      // Mirrors the M keyboard shortcut.
                      onPressed: game.audioService.toggleMute,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
