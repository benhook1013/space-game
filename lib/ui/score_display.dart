import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'hud_value_display.dart';

/// Displays the player's score with a star icon.
class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({super.key, required this.game});

  /// Reference to the running game providing score updates.
  final SpaceGame game;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return HudValueDisplay(
      valueListenable: game.score,
      icon: Icon(Icons.star, color: scheme.primary, size: 24),
    );
  }
}
