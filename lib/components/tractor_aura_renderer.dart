import 'dart:ui';

import 'package:flame/components.dart';

import '../constants.dart';
import 'player.dart';

/// Renders the player's tractor aura as a radial gradient.
class TractorAuraRenderer extends Component with ParentIsA<PlayerComponent> {
  final Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final auraCenter = Offset(parent.size.x / 2, parent.size.y / 2);
    final auraRadius = Constants.playerTractorAuraRadius;
    _paint.shader = Gradient.radial(
      auraCenter,
      auraRadius,
      [
        const Color(0x5500aaff),
        const Color(0x0000aaff),
      ],
    );
    canvas.drawCircle(auraCenter, auraRadius, _paint);
  }
}
