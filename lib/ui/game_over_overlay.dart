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
          const Text(
            'Game Over',
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<int>(
            valueListenable: game.score,
            builder: (context, value, _) => Text(
              'Final Score: $value',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<int>(
            valueListenable: game.highScore,
            builder: (context, value, _) => Text(
              'High Score: $value',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: game.startGame,
            child: const Text('Restart'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: game.returnToMenu,
            child: const Text('Menu'),
          ),
        ],
      ),
    );
  }
}
