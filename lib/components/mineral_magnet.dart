import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show RadialGradient;

import '../constants.dart';
import '../game/space_game.dart';
import 'player.dart';

/// Blue aura around the player that attracts nearby mineral pickups.
class MineralMagnetComponent extends PositionComponent
    with HasGameReference<SpaceGame> {
  MineralMagnetComponent({required this.player})
      : super(
          anchor: Anchor.center,
          priority: -1,
          size: Vector2.all(Constants.playerMagnetRange * 2),
        );

  /// Player that minerals move toward.
  final PlayerComponent player;

  final double _radius = Constants.playerMagnetRange;
  final double _speed = Constants.mineralMagnetSpeed;
  late final Paint _paint;

  @override
  Future<void> onLoad() async {
    _paint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x440099ff),
          Color(0x000099ff),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: _radius));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.setFrom(player.position);
    for (final mineral in game.mineralPickups) {
      final toPlayer = player.position - mineral.position;
      final distance = toPlayer.length;
      if (distance <= _radius && distance > 0) {
        mineral.position += toPlayer / distance * _speed * dt;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, _radius, _paint);
  }
}
