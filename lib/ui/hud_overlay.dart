import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'game_text.dart';

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
                    icon: const Icon(Icons.gps_fixed, color: Colors.white),
                    onPressed: game.toggleAutoAimRadius,
                  ),
                  IconButton(
                    // Mirrors the H keyboard shortcut.
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    onPressed: game.toggleHelp,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: game.audioService.muted,
                    builder: (context, muted, _) => IconButton(
                      // Mirrors the `M` keyboard shortcut.
                      icon: Icon(
                        muted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: game.audioService.toggleMute,
                    ),
                  ),
                  IconButton(
                    // Mirrors the Escape and P keyboard shortcuts.
                    icon: const Icon(Icons.pause, color: Colors.white),
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
