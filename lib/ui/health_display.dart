import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'hud_value_display.dart';

/// Displays the player's health with a heart icon.
class HealthDisplay extends StatelessWidget {
  const HealthDisplay({super.key, required this.game});

  /// Reference to the running game providing health updates.
  final SpaceGame game;

  @override
  Widget build(BuildContext context) {
    return HudValueDisplay(
      valueListenable: game.health,
      icon: const Icon(Icons.favorite, color: Colors.white, size: 24),
    );
  }
}
