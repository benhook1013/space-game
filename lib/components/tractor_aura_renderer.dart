import 'dart:ui';

import 'package:flame/components.dart';

import '../constants.dart';
import '../game/space_game.dart';
import 'player.dart';

/// Renders the player's tractor aura as a radial gradient.
class TractorAuraRenderer extends Component
    with ParentIsA<PlayerComponent>, HasGameReference<SpaceGame> {
  final Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final auraCenter = Offset(parent.size.x / 2, parent.size.y / 2);
    final auraRadius = game.upgradeService.tractorRange;
    _paint.shader = Gradient.radial(
      auraCenter,
      auraRadius,
      [
        Constants.tractorAuraInnerColor,
        Constants.tractorAuraOuterColor,
      ],
    );
    canvas.drawCircle(auraCenter, auraRadius, _paint);
  }
}
