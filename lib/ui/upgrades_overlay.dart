import 'package:flutter/material.dart';

import '../game/space_game.dart';
import '../services/upgrade_service.dart';
import 'game_text.dart';
import 'overlay_widgets.dart';

/// Overlay shown for choosing upgrades.
class UpgradesOverlay extends StatefulWidget {
  const UpgradesOverlay({super.key, required this.game});

  /// Reference to the running game.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'upgradesOverlay';

  @override
  State<UpgradesOverlay> createState() => _UpgradesOverlayState();
}

class _UpgradesOverlayState extends State<UpgradesOverlay> {
  @override
  Widget build(BuildContext context) {
    final service = widget.game.upgradeService;
    return OverlayLayout(
      dimmed: true,
      builder: (context, spacing, iconSize) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameText(
              'Upgrades',
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 1,
            ),
            SizedBox(height: spacing),
            ValueListenableBuilder<int>(
              valueListenable: widget.game.minerals,
              builder: (context, minerals, _) {
                return Column(
                  children: [
                    for (final upgrade in service.upgrades)
                      _buildUpgradeRow(upgrade, minerals, service),
                  ],
                );
              },
            ),
            SizedBox(height: spacing),
            ElevatedButton(
              onPressed: () => widget.game.ui.toggleUpgrades(),
              child: const GameText(
                'Resume',
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: spacing),
            MuteButton(game: widget.game, iconSize: iconSize),
          ],
        );
      },
    );
  }

  Widget _buildUpgradeRow(
    Upgrade upgrade,
    int minerals,
    UpgradeService service,
  ) {
    final purchased = service.isPurchased(upgrade.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameText(
            '${upgrade.name} (${upgrade.cost})',
            maxLines: 1,
          ),
          const SizedBox(width: 8),
          if (purchased)
            const GameText('Purchased', maxLines: 1)
          else
            ElevatedButton(
              onPressed: minerals >= upgrade.cost
                  ? () {
                      setState(() {
                        service.buy(upgrade);
                      });
                    }
                  : null,
              child: const GameText('Buy', maxLines: 1),
            ),
        ],
      ),
    );
  }
}
