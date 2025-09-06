import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'game_text.dart';
import 'overlay_widgets.dart';

/// Overlay listing available controls.
class HelpOverlay extends StatelessWidget {
  const HelpOverlay({super.key, required this.game});

  /// Reference to the running game.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'helpOverlay';

  @override
  Widget build(BuildContext context) {
    return OverlayLayout(
      dimmed: true,
      builder: (context, spacing, iconSize) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameText(
              'Controls',
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 1,
            ),
            SizedBox(height: spacing),
            const GameText(
              'Move: WASD / Arrow keys\n'
              'Shoot: Space\n'
              'Mute: M\n'
              'Toggle Minimap: N or HUD button\n'
              'Toggle Debug: F1\n'
              'Toggle Range Rings: B or HUD button\n'
              'Upgrades: U or HUD button\n'
              'Settings: HUD button\n'
              'Pause/Resume: Esc or P\n'
              'Start/Restart: Enter\n'
              'Restart anytime: R\n'
              'Toggle Help: H or Esc',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing),
            ElevatedButton(
              onPressed: game.toggleHelp,
              child: const GameText(
                'Close',
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
