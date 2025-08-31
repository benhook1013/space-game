import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/explosion.dart';
import 'package:space_game/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('removes itself after lifetime expires', () async {
    await Flame.images.loadAll(Assets.explosions);
    final game = FlameGame();
    final explosion = ExplosionComponent(position: Vector2.zero());
    await game.add(explosion);
    await game.ready();
    final total = Constants.explosionLifetime;
    game.update(total + 0.1);
    await game.ready();
    expect(explosion.isMounted, isFalse);
  });
}
