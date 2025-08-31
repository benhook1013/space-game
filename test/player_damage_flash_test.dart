import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/components/player.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/game/game_state_machine.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/overlay_service.dart';
import 'package:space_game/services/storage_service.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: 'players/player1.png');

  @override
  Future<void> onLoad() async {}
}

class _TestGame extends SpaceGame {
  _TestGame({required StorageService storage, required AudioService audio})
      : super(storageService: storage, audioService: audio);

  @override
  Future<void> onLoad() async {
    overlayService = OverlayService(this);
    stateMachine = GameStateMachine(
      overlays: overlayService,
      onStart: () {},
      onPause: () {},
      onResume: () {},
      onGameOver: () {},
      onMenu: () {},
    )..state = GameState.playing;
    final keyDispatcher = KeyDispatcher();
    add(keyDispatcher);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    add(player);
    onGameResize(Vector2.all(Constants.playerSize * Constants.playerScale * 2));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player flashes red when hit', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();

    expect(game.player.paint.color, const Color(0xffffffff));

    game.hitPlayer();
    expect(game.player.paint.color, const Color(0xffff0000));

    game.player.update(Constants.playerDamageFlashDuration);
    expect(game.player.paint.color, const Color(0xffffffff));
  });
}
