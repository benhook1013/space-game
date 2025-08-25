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
    return Container(
      color: Colors.black54,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                'Controls',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 20),
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
                maxLines: 9,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: game.toggleHelp,
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const AutoSizeText(
                  'Close',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
