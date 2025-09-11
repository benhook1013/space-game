import 'dart:math' as math;

import 'package:flame/components.dart';

/// Utilities for working with angles.
///
/// Normalises angles to the `[-π, π]` range to avoid discontinuities when
/// comparing or interpolating rotations.
///
double normalizeAngle(double angle) {
  angle %= 2 * math.pi;
  if (angle <= -math.pi) {
    angle += 2 * math.pi;
  } else if (angle > math.pi) {
    angle -= 2 * math.pi;
  }
  return angle;
}

/// Converts a directional [vector] into a Flame angle.
///
/// In Flame, an angle of `0` points upwards. This helper maps a vector using
/// [`atan2`] and applies the required offset so sprites face the vector's
/// heading.
double vectorToFlameAngle(Vector2 vector) =>
    math.atan2(vector.y, vector.x) + math.pi / 2;
