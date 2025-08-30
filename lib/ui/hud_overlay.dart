import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'game_text.dart';
import 'responsive.dart';

/// Simple heads-up display shown during play.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  /// Running game instance providing score updates.
  final SpaceGame game;

  /// Overlay identifier used by [GameWidget].
  static const String id = 'hudOverlay';

  @override
  Widget build(BuildContext context) {
    final iconSize = responsiveIconSizeFromContext(context);
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: game.score,
                      builder: (context, value, _) => GameText(
                        'Score: $value',
                        maxLines: 1,
                      ),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: game.highScore,
                      builder: (context, value, _) => GameText(
                        'High: $value',
                        maxLines: 1,
                      ),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: game.health,
                      builder: (context, value, _) => GameText(
                        'Health: $value',
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    iconSize: iconSize,
                    icon: const Icon(Icons.gps_fixed, color: Colors.white),
                    onPressed: game.toggleAutoAimRadius,
                  ),
                  IconButton(
                    iconSize: iconSize,
                    // Mirrors the H keyboard shortcut.
                    icon: const Icon(Icons.help_outline,
                        color: GameText.defaultColor),
                    onPressed: game.toggleHelp,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: game.audioService.muted,
                    builder: (context, muted, _) => IconButton(
                      iconSize: iconSize,
                      // Mirrors the `M` keyboard shortcut.
                      icon: Icon(
                        muted ? Icons.volume_off : Icons.volume_up,
                        color: GameText.defaultColor,
                      ),
                      onPressed: game.audioService.toggleMute,
                    ),
                  ),
                  IconButton(
                    iconSize: iconSize,
                    // Mirrors the Escape and P keyboard shortcuts.
                    icon: const Icon(Icons.pause, color: GameText.defaultColor),
                    onPressed: game.pauseGame,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
