import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../constants.dart';
import '../game/space_game.dart';
import 'game_text.dart';
import 'overlay_widgets.dart';

/// Start screen shown before gameplay begins.
class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key, required this.game});

  /// Reference to the running game.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'menuOverlay';

  @override
  Widget build(BuildContext context) {
    return OverlayLayout(
      builder: (context, spacing, iconSize) {
        final shortestSide = spacing / 0.02;
        final playerSize = math.min(
          shortestSide * 0.12,
          Constants.playerSize *
              (Constants.spriteScale + Constants.playerScale),
        );
        return Column(
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
                        width: playerSize,
                        height: playerSize,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected == i
                                ? GameText.defaultColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/${Assets.players[i]}',
                          fit: BoxFit.contain,
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
