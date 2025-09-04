import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('camera tracks player movement', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.players, ...Assets.explosions]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(PauseOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    await game.ready();
    game.onGameResize(Vector2.all(100));

    game.joystick.removeFromParent();
    await game.ready();

    game.player.position.add(Vector2(10, 20));
    game.update(0);

    expect(game.camera.viewfinder.position, game.player.position);
  });
}
