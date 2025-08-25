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
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.biggest.shortestSide;
        final titleFontSize = shortestSide * 0.08;
        final uiFontSize = shortestSide * 0.04;
        final spacing = shortestSide * 0.02;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Space Miner',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: titleFontSize,
                      color: Colors.white,
                    ),
              ),
              SizedBox(height: spacing),
              ValueListenableBuilder<int>(
                valueListenable: game.highScore,
                builder: (context, value, _) => value > 0
                    ? Text(
                        'High Score: $value',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: uiFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: spacing),
              TextButton(
                onPressed: () => game.resetHighScore(),
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: uiFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Reset High Score'),
              ),
              SizedBox(height: spacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: game.startGame,
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                        fontSize: uiFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Start'),
                  ),
                  SizedBox(width: spacing),
                  ElevatedButton(
                    // Mirrors the H keyboard shortcut.
                    onPressed: game.toggleHelp,
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                        fontSize: uiFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Help'),
                  ),
                  SizedBox(width: spacing),
                  ValueListenableBuilder<bool>(
                    valueListenable: game.audioService.muted,
                    builder: (context, muted, _) => IconButton(
                      iconSize: uiFontSize * 1.2,
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
      },
    );
  }
}
