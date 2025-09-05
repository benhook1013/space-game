import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/util/collision_utils.dart';

class _Body extends PositionComponent with CollisionCallbacks, SolidBody {}

void main() {
  test('equal size bodies push apart equally', () {
    final a = _Body()
      ..size = Vector2.all(10)
      ..position = Vector2.zero();
    final b = _Body()
      ..size = Vector2.all(10)
      ..position = Vector2(8, 0);

    a.onCollision(<Vector2>{}, b);

    expect(a.position.x, closeTo(-1, 0.0001));
    expect(b.position.x, closeTo(9, 0.0001));
  });

  test('smaller body moved entirely when colliding with larger one', () {
    final small = _Body()
      ..size = Vector2.all(10)
      ..position = Vector2.zero();
    final big = _Body()
      ..size = Vector2.all(20)
      ..position = Vector2(8, 0);

    small.onCollision(<Vector2>{}, big);

    expect(small.position.x, closeTo(-7, 0.0001));
    expect(big.position.x, closeTo(8, 0.0001));
  });

  test('larger body pushes smaller one out of the way', () {
    final big = _Body()
      ..size = Vector2.all(20)
      ..position = Vector2.zero();
    final small = _Body()
      ..size = Vector2.all(10)
      ..position = Vector2(8, 0);

    big.onCollision(<Vector2>{}, small);

    expect(big.position.x, closeTo(0, 0.0001));
    expect(small.position.x, closeTo(15, 0.0001));
  });
}
