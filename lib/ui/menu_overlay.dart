import 'package:auto_size_text/auto_size_text.dart';
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
        final spacing = shortestSide * 0.02;
        final iconSize = shortestSide * 0.05;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                'Space Miner',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white),
                maxLines: 1,
              ),
              SizedBox(height: spacing),
              ValueListenableBuilder<int>(
                valueListenable: game.highScore,
                builder: (context, value, _) => value > 0
                    ? AutoSizeText(
                        'High Score: $value',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: spacing),
              TextButton(
                onPressed: () => game.resetHighScore(),
                child: const AutoSizeText(
                  'Reset High Score',
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: spacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: game.startGame,
                    child: const AutoSizeText(
                      'Start',
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: spacing),
                  ElevatedButton(
                    // Mirrors the H keyboard shortcut.
                    onPressed: game.toggleHelp,
                    child: const AutoSizeText(
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
