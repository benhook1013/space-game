import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'game_text.dart';

/// Generic pill-shaped display showing an icon next to an integer value.
class HudValueDisplay extends StatelessWidget {
  const HudValueDisplay({
    super.key,
    required this.icon,
    required this.valueListenable,
  });

  /// Icon widget shown before the value.
  final Widget icon;

  /// Notifier providing the current value to render.
  final ValueListenable<int> valueListenable;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: valueListenable,
      builder: (context, value, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            GameText('$value', maxLines: 1),
          ],
        ),
      ),
    );
  }
}
