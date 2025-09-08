import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/nearest_component.dart';

class _TestComponent extends PositionComponent {
  _TestComponent(Vector2 position) {
    this.position = position;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('findClosestComponent returns nearest within range', () {
    final components = [
      _TestComponent(Vector2(10, 0)),
      _TestComponent(Vector2(5, 0)),
    ];
    final origin = Vector2.zero();
    final result = components.findClosest(
      origin,
      maxDistance: 8,
    );
    expect(result, equals(components[1]));
  });

  test('findClosestComponent returns null when none in range', () {
    final components = [
      _TestComponent(Vector2(10, 0)),
      _TestComponent(Vector2(5, 0)),
    ];
    final origin = Vector2.zero();
    final result = components.findClosest(
      origin,
      maxDistance: 4,
    );
    expect(result, isNull);
  });

  test('findClosestComponent with predicate', () {
    final components = [
      _TestComponent(Vector2(10, 0)),
      _TestComponent(Vector2(5, 0)),
    ];
    final origin = Vector2.zero();
    final result = components.findClosest(
      origin,
      where: (c) => c.position.x > 6,
    );
    expect(result, equals(components[0]));
  });
}
