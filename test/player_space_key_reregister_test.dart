import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';
import 'test_images.dart';
import 'test_joystick.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: Assets.players.first);

  bool started = false;

  @override
  void startShooting() {
    started = true;
  }
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    keyDispatcher = KeyDispatcher();
    await add(keyDispatcher);
    await controlManager.init();
    controlManager.joystick.removeFromParent();
    controlManager.joystick = TestJoystick();
    await add(controlManager.joystick);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player re-registers space key after remount', () async {
    SharedPreferences.setMockInitialValues({});
    await loadTestImages(Assets.players);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(PauseOverlay.id, (_, __) => const SizedBox());
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
    await game.onLoad();
    game.onGameResize(Vector2.all(100));
    await game.ready();
    game.controlManager.joystick.onGameResize(game.size);
    game.update(0);
    game.update(0);

    final player = _TestPlayer(
      joystick: game.controlManager.joystick,
      keyDispatcher: game.keyDispatcher,
    );
    await game.add(player);
    await game.ready();
    player.onMount();
    game.update(0);
    game.update(0);

    player.removeFromParent();
    await game.ready();
    game.update(0);
    game.update(0);

    await game.add(player);
    await game.ready();
    player.onMount();
    game.update(0);
    game.update(0);

    game.keyDispatcher.onKeyEvent(
      KeyDownEvent(
        logicalKey: LogicalKeyboardKey.space,
        physicalKey: PhysicalKeyboardKey.space,
        timeStamp: Duration.zero,
      ),
      {LogicalKeyboardKey.space},
    );

    expect(player.started, isTrue);
  });
}
