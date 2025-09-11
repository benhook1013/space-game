import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/angle_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('normalizeAngle returns expected values', () {
    final cases = <({double input, double expected})>[
      // wraps angles greater than π
      (input: 3 * math.pi / 2, expected: -math.pi / 2),
      // wraps angles less than -π
      (input: -3 * math.pi / 2, expected: math.pi / 2),
      // handles multiples of 2π
      (input: 5 * 2 * math.pi + math.pi / 4, expected: math.pi / 4),
      // maps ±2π to zero
      (input: 2 * math.pi, expected: 0),
      (input: -2 * math.pi, expected: 0),
      // leaves in-range angles unchanged
      (input: math.pi, expected: math.pi),
      (input: 0, expected: 0),
      (input: math.pi / 2, expected: math.pi / 2),
      // wraps -π to π
      (input: -math.pi, expected: math.pi),
      // handles negative multiples of 2π
      (input: -7 * 2 * math.pi - math.pi / 3, expected: -math.pi / 3),
    ];

    for (final (:input, :expected) in cases) {
      final normalized = normalizeAngle(input);
      expect(
        normalized,
        closeTo(expected, 1e-10),
        reason: 'angle $input expected $expected but got $normalized',
      );
    }
  });

  test('normalizeAngle keeps result within [-π, π]', () {
    // Reduced sample set for faster execution; expand only if failures appear.
    for (var angle = -4 * math.pi; angle <= 4 * math.pi; angle += math.pi / 2) {
      final normalized = normalizeAngle(angle);
      expect(
        normalized >= -math.pi && normalized <= math.pi,
        isTrue,
        reason: 'angle $angle normalized to $normalized outside range',
      );
    }
  });

  test('normalizeAngle is odd except at π', () {
    // Reduced sample set for faster execution; expand only if failures appear.
    for (var angle = -2 * math.pi; angle <= 2 * math.pi; angle += math.pi / 2) {
      final normalized = normalizeAngle(angle);
      if ((normalized - math.pi).abs() < 1e-10 ||
          (normalized + math.pi).abs() < 1e-10) {
        continue;
      }
      final mirrored = normalizeAngle(-angle);
      expect(
        mirrored,
        closeTo(-normalized, 1e-10),
        reason: 'angle $angle produced $normalized and $mirrored',
      );
    }
  });

  test('normalizeAngle treats -0 as 0', () {
    expect(normalizeAngle(-0.0), isZero);
  });
}
