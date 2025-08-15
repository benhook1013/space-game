import 'package:flutter/material.dart';

import '../game/space_game.dart';

/// Simple heads-up display shown during play.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  /// Running game instance providing score updates.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'hudOverlay';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: ValueListenableBuilder<int>(
          valueListenable: game.score,
          builder: (context, value, _) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Score: $value',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
