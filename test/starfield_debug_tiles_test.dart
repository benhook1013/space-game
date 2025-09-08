import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/components/starfield.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('debugDrawTiles outlines tiles when enabled', () async {
    final game = FlameGame();
    game.onGameResize(Vector2.all(256));
    final starfield = StarfieldComponent(debugDrawTiles: true);
    await game.add(starfield);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    expect(starfield.debugDrawTiles, isTrue);
    starfield.render(canvas); // should draw without throwing
  });
}
