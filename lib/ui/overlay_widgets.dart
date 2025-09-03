import 'package:flutter/material.dart';

import '../game/space_game.dart';
import 'game_text.dart';
import 'responsive.dart';

/// Signature for builders used with [OverlayLayout].
typedef OverlayChildBuilder = Widget Function(
    BuildContext context, double spacing, double iconSize);

/// Provides a common responsive layout for overlays.
///
/// Calculates `spacing` and `iconSize` based on screen size and optionally
/// adds a dimmed background. The [builder] creates the actual overlay content.
class OverlayLayout extends StatelessWidget {
  const OverlayLayout({
    super.key,
    required this.builder,
    this.dimmed = false,
  });

  /// Builds the overlay content given responsive values.
  final OverlayChildBuilder builder;

  /// Whether to draw a translucent background behind the overlay.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.biggest.shortestSide;
        final spacing = shortestSide * 0.02;
        final iconSize = responsiveIconSize(constraints);

        Widget child = Center(child: builder(context, spacing, iconSize));
        if (dimmed) {
          child = Container(color: Colors.black54, child: child);
        }
        return child;
      },
    );
  }
}

/// Icon button that toggles the game's mute state.
class MuteButton extends StatelessWidget {
  const MuteButton({super.key, required this.game, required this.iconSize});

  final SpaceGame game;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: game.audioService.muted,
      builder: (context, muted, _) => IconButton(
        iconSize: iconSize,
        icon: Icon(
          muted ? Icons.volume_off : Icons.volume_up,
          color: GameText.defaultColor,
        ),
        onPressed: game.audioService.toggleMute,
      ),
    );
  }
}

/// Button that opens the help overlay.
///
/// Uses an icon when [iconSize] is provided, otherwise renders as an
/// [ElevatedButton] with text.
class HelpButton extends StatelessWidget {
  const HelpButton({super.key, required this.game, this.iconSize});

  final SpaceGame game;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    if (iconSize != null) {
      return IconButton(
        iconSize: iconSize,
        icon: const Icon(Icons.help_outline, color: GameText.defaultColor),
        onPressed: game.toggleHelp,
      );
    }
    return ElevatedButton(
      onPressed: game.toggleHelp,
      child: const GameText(
        'Help',
        maxLines: 1,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Icon button that opens the upgrades overlay.
class UpgradeButton extends StatelessWidget {
  const UpgradeButton({super.key, required this.game, required this.iconSize});

  final SpaceGame game;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: iconSize,
      icon: const Icon(Icons.upgrade, color: GameText.defaultColor),
      onPressed: game.toggleUpgrades,
    );
  }
}

/// Icon button that opens the runtime settings overlay.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key, required this.game, required this.iconSize});

  final SpaceGame game;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: iconSize,
      icon: const Icon(Icons.tune, color: GameText.defaultColor),
      onPressed: game.toggleSettings,
    );
  }
}
