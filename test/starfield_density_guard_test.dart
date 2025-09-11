import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/components/starfield.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('layer density <= 0 generates no stars', () {
    final zeroLayer =
        StarfieldComponent(layers: const [StarfieldLayerConfig(density: 0)]);
    final negativeLayer =
        StarfieldComponent(layers: const [StarfieldLayerConfig(density: -1)]);
    expect(zeroLayer.debugTileStarRadii(0, 0), isEmpty);
    expect(negativeLayer.debugTileStarRadii(0, 0), isEmpty);
  });

  test('zero density layer does not crash during update or debug render',
      () async {
    final game = FlameGame();
    game.onGameResize(Vector2.all(256));
    final starfield = StarfieldComponent(
      layers: const [StarfieldLayerConfig(density: 0)],
      debugDrawTiles: true,
    );
    await game.add(starfield);

    starfield.update(0);
    await starfield.debugWaitForPending();

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    expect(starfield.debugDrawTiles, isTrue);
    starfield.render(canvas); // should draw without throwing

    expect(starfield.debugTileStarRadii(0, 0), isEmpty);
  });
}
