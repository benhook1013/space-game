import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'game_text.dart';
import 'responsive.dart';

/// Overlay shown for choosing upgrades.
class UpgradesOverlay extends StatelessWidget {
  const UpgradesOverlay({super.key, required this.game});

  /// Reference to the running game.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'upgradesOverlay';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.biggest.shortestSide;
        final spacing = shortestSide * 0.02;
        final iconSize = responsiveIconSize(constraints);

        return Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GameText(
                  'Upgrades',
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxLines: 1,
                ),
                SizedBox(height: spacing),
                const GameText(
                  'Coming soon',
                  maxLines: 1,
                ),
                SizedBox(height: spacing),
                ElevatedButton(
                  // Mirrors the U and Escape keyboard shortcuts.
                  onPressed: game.toggleUpgrades,
                  child: const GameText(
                    'Resume',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: spacing),
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
          ),
        );
      },
    );
  }
}
