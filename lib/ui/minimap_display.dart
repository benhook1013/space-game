import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flame/components.dart';

import '../components/asteroid.dart';
import '../components/enemy.dart';
import '../components/mineral.dart';
import '../game/space_game.dart';

/// Simple circular minimap showing nearby entities relative to the player.
///
/// The player appears as a small arrow indicating the current heading, while
/// enemies, asteroids and mineral pickups render as dots.
class MiniMapDisplay extends StatefulWidget {
  const MiniMapDisplay({super.key, required this.game, this.size = 80});

  final SpaceGame game;
  final double size;

  @override
  State<MiniMapDisplay> createState() => _MiniMapDisplayState();
}

class _MiniMapDisplayState extends State<MiniMapDisplay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(() {}))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _MiniMapPainter(widget.game),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  _MiniMapPainter(this.game);

  final SpaceGame game;
  static const double _scale = 0.05;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final borderPaint = Paint()
      ..color = game.colorScheme.primary
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, borderPaint);

    final playerPaint = Paint()..color = game.colorScheme.primary;
    const double arrowRadius = 6;
    // Player's angle is 0 when facing north, but Canvas expects 0 on the east.
    // Shift by 90 degrees so the minimap arrow aligns with the ship heading.
    final angle = game.player.angle - math.pi / 2;
    final tip = Offset(
      center.dx + math.cos(angle) * arrowRadius,
      center.dy + math.sin(angle) * arrowRadius,
    );
    final left = Offset(
      center.dx + math.cos(angle + 5 * math.pi / 6) * arrowRadius,
      center.dy + math.sin(angle + 5 * math.pi / 6) * arrowRadius,
    );
    final right = Offset(
      center.dx + math.cos(angle - 5 * math.pi / 6) * arrowRadius,
      center.dy + math.sin(angle - 5 * math.pi / 6) * arrowRadius,
    );
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(path, playerPaint);

    final enemyPaint = Paint()..color = Colors.redAccent;
    final asteroidPaint = Paint()..color = Colors.grey;
    final mineralPaint = Paint()..color = Colors.amber;

    final playerPos = game.player.position;

    void drawDot(PositionComponent c, Paint paint) {
      final offset = (c.position - playerPos) * _scale;
      if (offset.length <= radius) {
        canvas.drawCircle(center + Offset(offset.x, offset.y), 2, paint);
      }
    }

    for (final enemy in game.children.whereType<EnemyComponent>()) {
      drawDot(enemy, enemyPaint);
    }
    for (final asteroid in game.children.whereType<AsteroidComponent>()) {
      drawDot(asteroid, asteroidPaint);
    }
    for (final mineral in game.children.whereType<MineralComponent>()) {
      drawDot(mineral, mineralPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) => true;
}
