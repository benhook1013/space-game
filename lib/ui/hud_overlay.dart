import 'package:flutter/material.dart';

import '../game/space_game.dart';

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: game.score,
              builder: (context, value, _) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Score: $value',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: game.audioService.muted,
              builder: (context, muted, _) => IconButton(
                icon: Icon(
                  muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: game.audioService.toggleMute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
