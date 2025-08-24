import 'package:flutter/material.dart';

import '../game/space_game.dart';

/// Start screen shown before gameplay begins.
class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key, required this.game});

  /// Reference to the running game.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'menuOverlay';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Space Miner',
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<int>(
            valueListenable: game.highScore,
            builder: (context, value, _) => value > 0
                ? Text(
                    'High Score: $value',
                    style: const TextStyle(color: Colors.white),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: game.startGame,
                child: const Text('Start'),
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
