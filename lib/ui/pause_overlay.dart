import 'package:flutter/material.dart';

import '../game/space_game.dart';

/// Overlay shown when the game is paused.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  /// Reference to the running game.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'pauseOverlay';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Paused',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                // Mirrors the Escape and P keyboard shortcuts.
                onPressed: game.resumeGame,
                child: const Text('Resume'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                // Mirrors the R keyboard shortcut.
                onPressed: game.startGame,
                child: const Text('Restart'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                // Mirrors the Q keyboard shortcut.
                onPressed: game.returnToMenu,
                child: const Text('Menu'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                // Mirrors the H keyboard shortcut.
                onPressed: game.toggleHelp,
                child: const Text('Help'),
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
