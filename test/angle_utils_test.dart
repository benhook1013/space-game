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
}
