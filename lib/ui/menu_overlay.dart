import 'package:flutter/material.dart';

import '../game/space_game.dart';
import '../assets.dart';
import 'game_text.dart';

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
              GameText(
                'Space Miner',
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 1,
              ),
              SizedBox(height: spacing),
              ValueListenableBuilder<int>(
                valueListenable: game.highScore,
                builder: (context, value, _) => value > 0
                    ? GameText(
                        'High Score: $value',
                        maxLines: 1,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: spacing),
              TextButton(
                onPressed: () => game.resetHighScore(),
                child: const GameText(
                  'Reset High Score',
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: spacing),
              ValueListenableBuilder<int>(
                valueListenable: game.selectedPlayerIndex,
                builder: (context, selected, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < Assets.players.length; i++)
                      GestureDetector(
                        onTap: () => game.selectPlayer(i),
                        child: Container(
                          margin: EdgeInsets.all(spacing),
                          padding: EdgeInsets.all(spacing / 2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selected == i
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/${Assets.players[i]}',
                            width: shortestSide * 0.1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: spacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: game.startGame,
                    child: const GameText(
                      'Start',
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
