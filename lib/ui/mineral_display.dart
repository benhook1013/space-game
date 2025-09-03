import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/space_game.dart';
import 'hud_value_display.dart';

/// Displays the player's mineral count with an accompanying icon.
class MineralDisplay extends StatelessWidget {
  const MineralDisplay({super.key, required this.game});

  /// Reference to the running game providing mineral updates.
  final SpaceGame game;

  @override
  Widget build(BuildContext context) {
    return HudValueDisplay(
      valueListenable: game.minerals,
      icon: Image.asset(
        'assets/images/${Assets.mineralIcon}',
        width: 24,
        height: 24,
      ),
    );
  }
}
