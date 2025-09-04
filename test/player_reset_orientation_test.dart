import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/flame.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/assets.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';
import 'package:space_game/constants.dart';
import 'test_joystick.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player orientation resets on game start', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(PauseOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2.all(100));
    await game.ready();
    game.resumeEngine();
    game.joystick.removeFromParent();
    game.joystick = TestJoystick();
    await game.add(game.joystick);
    game.player
      ..setJoystick(game.joystick)
      ..resetInput();
    game.update(0);
    game.update(0);

    // Set a non-zero orientation and move the player away from center.
    game.player
      ..angle = 1
      ..position.setValues(20, 20);

    // Clear input before restarting.
    game.joystick.delta.setZero();
    game.joystick.relativeDelta.setZero();

    // Starting a new game should reset orientation and position.
    game.startGame();
    game.onGameResize(Vector2.all(100));
    await game.ready();
    game.update(0);
    game.update(0);
    expect(game.player.angle, 0);
    expect(game.player.position, Constants.worldSize / 2);

    // After update with no input, angle and position should remain unchanged.
    game.update(0.1);
    expect(game.player.angle, 0);
    expect(game.player.position, Constants.worldSize / 2);
  });
}
