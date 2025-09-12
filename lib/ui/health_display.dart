import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/space_game.dart';
import 'hud_value_display.dart';

/// Displays the player's health with a heart icon.
class HealthDisplay extends StatelessWidget {
  const HealthDisplay({super.key, required this.game});

  /// Reference to the running game providing health updates.
  final SpaceGame game;

  /// Vertical offset applied to nudge the heart icon upward.
  static const double _iconVerticalOffset = -2;

  /// Base size used for the heart icon before scaling.
  static const double _iconBaseSize = 22;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return HudValueDisplay(
      valueListenable: game.health,
      baseIconSize: _iconBaseSize,
      iconBuilder: (size) => Transform.translate(
        // Scale the offset with the icon size so text scaling stays balanced.
        offset: Offset(0, _iconVerticalOffset * (size / _iconBaseSize)),
        child: ImageIcon(
          AssetImage('assets/images/${Assets.healthIcon}'),
          color: scheme.error,
          size: size,
        ),
      ),
    );
  }
}
