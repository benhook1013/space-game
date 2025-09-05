import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

import '../components/asteroid.dart';
import '../components/enemy.dart';
import '../game/space_game.dart';

/// Simple minimap widget showing nearby asteroids and enemies.
class Minimap extends StatelessWidget {
  const Minimap({super.key, required this.game});

  /// Running game instance used to query entity positions.
  final SpaceGame game;

  /// Visual size of the minimap widget.
  static const double size = 80;

  /// World-space radius displayed by the minimap around the player.
  static const double worldRadius = 600;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MinimapPainter(game),
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  _MinimapPainter(this.game);

  final SpaceGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final playerPos = game.player.position;

    // Background and border
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawRect(Offset.zero & size, bgPaint);
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawRect(Offset.zero & size, border);

    final scale = size.width / (Minimap.worldRadius * 2);

    void drawEntity(Vector2 worldPos, Color color, double radius) {
      final rel = (worldPos - playerPos) * scale;
      if (rel.length <= size.width / 2) {
        canvas.drawCircle(
          Offset(size.width / 2 + rel.x, size.height / 2 + rel.y),
          radius,
          Paint()..color = color,
        );
      }
    }

    for (final asteroid in game.children.whereType<AsteroidComponent>()) {
      drawEntity(asteroid.position, Colors.grey, 2);
    }
    for (final enemy in game.children.whereType<EnemyComponent>()) {
      drawEntity(enemy.position, Colors.redAccent, 3);
    }

    // Player marker
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()..color = Colors.greenAccent,
    );
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter oldDelegate) => true;
}
