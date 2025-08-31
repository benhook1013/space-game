import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

import '../game/space_game.dart';

/// Mixin that renders component health when [SpaceGame.debugMode] is enabled.
mixin DebugHealthText on PositionComponent, HasGameReference<SpaceGame> {
  static final TextPaint _debugTextPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xffffffff),
      fontSize: 10,
    ),
  );

  /// Renders [health] above the component when debug mode is active.
  void renderHealth(Canvas canvas, int health) {
    if (!game.debugMode) {
      return;
    }
    final text = '$health';
    final tp = _debugTextPaint.toTextPainter(text);
    final position = Vector2(
      -tp.width / 2,
      -size.y / 2 - tp.height,
    );
    _debugTextPaint.render(canvas, text, position);
  }
}
