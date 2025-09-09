import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/angle_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('normalizeAngle wraps angles greater than pi', () {
    final angle = 3 * math.pi / 2;
    final normalized = normalizeAngle(angle);
    expect(normalized, closeTo(-math.pi / 2, 1e-10));
  });

  test('normalizeAngle wraps angles less than -pi', () {
    final angle = -3 * math.pi / 2;
    final normalized = normalizeAngle(angle);
    expect(normalized, closeTo(math.pi / 2, 1e-10));
  });

  test('normalizeAngle handles multiples of 2π', () {
    final angle = 5 * 2 * math.pi + math.pi / 4;
    final normalized = normalizeAngle(angle);
    expect(normalized, closeTo(math.pi / 4, 1e-10));
  });

  test('normalizeAngle leaves in-range angles unchanged', () {
    expect(normalizeAngle(math.pi), closeTo(math.pi, 1e-10));
    expect(normalizeAngle(0), closeTo(0, 1e-10));
    expect(normalizeAngle(math.pi / 2), closeTo(math.pi / 2, 1e-10));
  });

  test('normalizeAngle wraps -π to π', () {
    expect(normalizeAngle(-math.pi), closeTo(math.pi, 1e-10));
  });

  test('normalizeAngle handles negative multiples of 2π', () {
    final angle = -7 * 2 * math.pi - math.pi / 3;
    final normalized = normalizeAngle(angle);
    expect(normalized, closeTo(-math.pi / 3, 1e-10));
  });

  test('normalizeAngle keeps result within [-π, π]', () {
    for (var angle = -20 * math.pi;
        angle <= 20 * math.pi;
        angle += math.pi / 5) {
      final normalized = normalizeAngle(angle);
      expect(
        normalized >= -math.pi && normalized <= math.pi,
        isTrue,
        reason: 'angle $angle normalized to $normalized outside range',
      );
    }
  });
}
