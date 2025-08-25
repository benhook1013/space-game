import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../game/space_game.dart';

/// Overlay listing available controls.
class HelpOverlay extends StatelessWidget {
  const HelpOverlay({super.key, required this.game});

  /// Reference to the running game.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'helpOverlay';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.biggest.shortestSide;
        final spacing = shortestSide * 0.02;

        return Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoSizeText(
                  'Controls',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                  maxLines: 1,
                ),
                SizedBox(height: spacing),
                const AutoSizeText(
                  'Move: WASD / Arrow keys\n'
                  'Shoot: Space\n'
                  'Mute: M\n'
                  'Pause/Resume: Esc or P\n'
                  'Start/Restart: Enter\n'
                  'Restart anytime: R\n'
                  'Menu: Q (pause/game over), Esc (game over)\n'
                  'Toggle Help: H or Esc',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing),
                ElevatedButton(
                  onPressed: game.toggleHelp,
                  child: const AutoSizeText(
                    'Close',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold),
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
