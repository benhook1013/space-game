import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/space_game.dart';
import 'game_text.dart';

/// Displays the player's mineral count with an accompanying icon.
class MineralDisplay extends StatelessWidget {
  const MineralDisplay({super.key, required this.game});

  /// Reference to the running game providing mineral updates.
  final SpaceGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.minerals,
      builder: (context, value, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/${Assets.mineralIcon}',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            GameText('$value', maxLines: 1),
          ],
        ),
      ),
    );
  }
}
