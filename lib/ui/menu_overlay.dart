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
            builder: (context, value, _) =>
                value > 0
                    ? Text(
                        'High Score: $value',
                        style: const TextStyle(color: Colors.white),
                      )
                    : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: game.startGame,
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
