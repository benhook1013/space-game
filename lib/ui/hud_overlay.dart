import 'package:flutter/material.dart';

import '../game/space_game.dart';
import '../game/game_state.dart';
import 'responsive.dart';
import 'overlay_widgets.dart';
import 'mineral_display.dart';
import 'score_display.dart';
import 'health_display.dart';

/// Simple heads-up display shown during play.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  /// Running game instance providing score updates.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'hudOverlay';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: game.settingsService.hudButtonScale,
      builder: (context, scale, _) {
        final iconSize = responsiveIconSizeFromContext(context) * scale;
        return SafeArea(
          child: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ScoreDisplay(game: game),
                        ),
                        const SizedBox(width: 8),
                        MineralDisplay(game: game),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: HealthDisplay(game: game),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      children: [
                        // Shows or hides targeting, tractor and mining range rings.
                        IconButton(
                          iconSize: iconSize,
                          icon: Icon(
                            Icons.gps_fixed,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: game.toggleAutoAimRadius,
                        ),
                        UpgradeButton(game: game, iconSize: iconSize),
                        HelpButton(game: game, iconSize: iconSize),
                        SettingsButton(game: game, iconSize: iconSize),
                        MuteButton(game: game, iconSize: iconSize),
                        ValueListenableBuilder<GameState>(
                          valueListenable: game.stateMachine.stateNotifier,
                          builder: (context, state, _) {
                            final paused = state == GameState.paused;
                            return IconButton(
                              iconSize: iconSize,
                              // Mirrors the Escape and P keyboard shortcuts.
                              icon: Icon(
                                paused ? Icons.play_arrow : Icons.pause,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed:
                                  paused ? game.resumeGame : game.pauseGame,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
