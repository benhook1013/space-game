import 'dart:math' as math;

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
