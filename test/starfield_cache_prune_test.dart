import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/components/starfield.dart';
import 'package:space_game/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  int _tileCount(Vector2 cameraPos, Vector2 viewSize) {
    final left = cameraPos.x - viewSize.x / 2;
    final top = cameraPos.y - viewSize.y / 2;
    final right = left + viewSize.x;
    final bottom = top + viewSize.y;
    final startX = (left / Constants.starfieldTileSize).floor();
    final endX = (right / Constants.starfieldTileSize).floor();
    final startY = (top / Constants.starfieldTileSize).floor();
    final endY = (bottom / Constants.starfieldTileSize).floor();
    return (endX - startX + 1) * (endY - startY + 1);
  }

  test('prunes tiles outside camera range', () async {
    final game = FlameGame();
    game.onGameResize(Vector2.all(512));
    final starfield = StarfieldComponent();
    await game.add(starfield);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    game.camera.viewfinder.position = Vector2.zero();
    starfield.render(canvas);
    final originExpected =
        _tileCount(game.camera.viewfinder.position, game.size);
    expect(starfield.debugCacheSize, originExpected);

    game.camera.viewfinder.position = Vector2(3000, 0);
    starfield.render(canvas);
    final movedExpected =
        _tileCount(game.camera.viewfinder.position, game.size);
    expect(starfield.debugCacheSize, movedExpected);
  });
}
