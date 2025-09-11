import 'package:flutter/material.dart';

import '../assets.dart';
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
        final iconSize = constraints.responsiveIconSize();

        Widget child = Center(child: builder(context, spacing, iconSize));
        // Ensure overlays have a Material ancestor so widgets like ListTile
        // don't paint an opaque background that covers the game.
        child = Material(
          type: MaterialType.transparency,
          child: child,
        );
        if (dimmed) {
          final scheme = Theme.of(context).colorScheme;
          child = Container(
            color: scheme.scrim.withValues(alpha: 0.54),
            child: child,
          );
        }
        return child;
      },
    );
  }
}

/// Reusable icon button that applies a consistent color scheme.
class GameIconButton extends StatelessWidget {
  const GameIconButton({
    super.key,
    required this.icon,
    required this.iconSize,
    this.onPressed,
    this.color,
  });

  final Widget icon;
  final double iconSize;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;
    return IconButton(
      iconSize: iconSize,
      onPressed: onPressed,
      color: iconColor,
      icon: icon,
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
      builder: (context, muted, _) {
        return GameIconButton(
          icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
          iconSize: iconSize,
          onPressed: game.audioService.toggleMute,
        );
      },
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
      return GameIconButton(
        icon: const Icon(Icons.help_outline),
        iconSize: iconSize!,
        onPressed: () => game.ui.toggleHelp(),
      );
    }
    return ElevatedButton(
      onPressed: () => game.ui.toggleHelp(),
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
    return GameIconButton(
      icon: const Icon(Icons.upgrade),
      iconSize: iconSize,
      onPressed: () => game.ui.toggleUpgrades(),
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
    return GameIconButton(
      icon: ImageIcon(
        AssetImage('assets/images/${Assets.settingsIcon}'),
      ),
      iconSize: iconSize,
      onPressed: () => game.ui.toggleSettings(),
    );
  }
}

/// Icon button that toggles the minimap visibility.
class MinimapButton extends StatelessWidget {
  const MinimapButton({super.key, required this.game, required this.iconSize});

  final SpaceGame game;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GameIconButton(
      icon: const Icon(Icons.map),
      iconSize: iconSize,
      color: Theme.of(context).colorScheme.onSurface,
      onPressed: () => game.ui.toggleMinimap(),
    );
  }
}
