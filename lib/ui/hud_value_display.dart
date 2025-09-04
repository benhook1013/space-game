import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'game_text.dart';

/// Generic pill-shaped display showing an icon next to an integer value.
class HudValueDisplay extends StatelessWidget {
  const HudValueDisplay({
    super.key,
    required this.iconBuilder,
    required this.valueListenable,
    this.baseIconSize = 24,
  });

  /// Builds the icon widget, allowing the size to scale with text.
  final Widget Function(double size) iconBuilder;

  /// Base size for the icon before scaling is applied.
  final double baseIconSize;

  /// Notifier providing the current value to render.
  final ValueListenable<int> valueListenable;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget buildDisplay(int value, double scale) {
      final iconSize = baseIconSize * scale;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.onSurface),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconBuilder(iconSize),
            const SizedBox(width: 8),
            GameText('$value', maxLines: 1),
          ],
        ),
      );
    }

    final textScale = GameText.textScale;
    if (textScale != null) {
      return ValueListenableBuilder<double>(
        valueListenable: textScale,
        builder: (context, scale, _) => ValueListenableBuilder<int>(
          valueListenable: valueListenable,
          builder: (context, value, _) => buildDisplay(value, scale),
        ),
      );
    }

    return ValueListenableBuilder<int>(
      valueListenable: valueListenable,
      builder: (context, value, _) => buildDisplay(value, 1),
    );
  }
}
