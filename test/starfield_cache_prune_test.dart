import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/components/starfield.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('prunes tiles outside camera range', () async {
    final game = FlameGame();
    game.onGameResize(Vector2.all(512));
    final starfield = StarfieldComponent(
      layers: const [StarfieldLayerConfig(maxCacheTiles: 16)],
    );
    await game.add(starfield);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    game.camera.viewfinder.position = Vector2.zero();
    starfield.update(0);
    await starfield.debugWaitForPending();
    starfield.render(canvas);
    const originExpected = 16; // includes cache margin
    expect(starfield.debugCacheSize(), originExpected);

    game.camera.viewfinder.position = Vector2(3000, 0);
    starfield.update(0);
    await starfield.debugWaitForPending();
    starfield.render(canvas);
    const movedExpected = 16; // old tiles pruned by LRU
    expect(starfield.debugCacheSize(), movedExpected);
  });
}
