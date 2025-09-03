import 'package:flutter/material.dart';

import 'game_text.dart';
import 'overlay_widgets.dart';

/// Overlay shown when the game is paused.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key});

  /// Overlay identifier used by [GameWidget].
  static const String id = 'pauseOverlay';

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: OverlayLayout(
        builder: (context, spacing, __) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameText(
                'PAUSED',
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 1,
              ),
              SizedBox(height: spacing),
              const GameText(
                'Press Esc or P to resume',
                maxLines: 1,
              ),
            ],
          );
        },
      ),
    );
  }
}
