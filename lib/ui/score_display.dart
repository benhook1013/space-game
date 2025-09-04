import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/space_game.dart';
import 'hud_value_display.dart';

/// Displays the player's score with a star icon.
class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({super.key, required this.game});

  /// Reference to the running game providing score updates.
  final SpaceGame game;

  /// Gold colour used for the score icon.
  static const Color _goldColor = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return HudValueDisplay(
      valueListenable: game.score,
      iconBuilder: (size) => ImageIcon(
        AssetImage('assets/images/${Assets.scoreIcon}'),
        color: _goldColor,
        size: size,
      ),
    );
  }
}
