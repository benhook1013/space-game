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
        builder: (context, _, __) {
          return GameText(
            'PAUSED',
            style: Theme.of(context).textTheme.headlineMedium,
            maxLines: 1,
          );
        },
      ),
    );
  }
}
