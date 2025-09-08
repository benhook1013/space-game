import 'dart:ui';

import 'package:flame/components.dart';

import '../constants.dart';

/// Mixin that applies a temporary red tint when [flashDamage] is called.
///
/// Components mixing this in must expose a [paint] via [HasPaint]. The flash
/// duration defaults to [Constants.playerDamageFlashDuration] but can be
/// overridden.
///
/// The mixin handles fading the colour filter over time during [update].
mixin DamageFlash on Component, HasPaint {
  static const _damageColor = Color(0xffff0000);

  double _flashTime = 0;

  /// Duration that the tint remains visible.
  double get damageFlashDuration => Constants.playerDamageFlashDuration;

  /// Triggers the red flash effect.
  void flashDamage() {
    _flashTime = damageFlashDuration;
    paint.colorFilter = ColorFilter.mode(_damageColor, BlendMode.srcATop);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTime > 0) {
      _flashTime -= dt;
      if (_flashTime <= 0) {
        paint.colorFilter = null;
      } else {
        final alpha =
            (255 * (_flashTime / damageFlashDuration)).clamp(0, 255).toInt();
        paint.colorFilter =
            ColorFilter.mode(_damageColor.withAlpha(alpha), BlendMode.srcATop);
      }
    }
  }
}
