import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../game/space_game.dart';

/// Overlay displayed when the player dies.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  /// Reference to the running game instance.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'gameOverOverlay';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AutoSizeText(
            'Game Over',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white),
            maxLines: 1,
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<int>(
            valueListenable: game.score,
            builder: (context, value, _) => AutoSizeText(
              'Final Score: $value',
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<int>(
            valueListenable: game.highScore,
            builder: (context, value, _) => AutoSizeText(
              'High Score: $value',
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                // Mirrors the Enter and R keyboard shortcuts.
                onPressed: game.startGame,
                child: const AutoSizeText('Restart', maxLines: 1),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                // Mirrors the Q and Escape keyboard shortcuts.
                onPressed: game.returnToMenu,
                child: const AutoSizeText('Menu', maxLines: 1),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                // Mirrors the H keyboard shortcut.
                onPressed: game.toggleHelp,
                child: const AutoSizeText('Help', maxLines: 1),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<bool>(
                valueListenable: game.audioService.muted,
                builder: (context, muted, _) => IconButton(
                  icon: Icon(
                    muted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
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
  }
}
