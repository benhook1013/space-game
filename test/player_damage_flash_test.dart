import 'package:flame/components.dart';
import 'package:flame/flame.dart';
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
import 'package:space_game/assets.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: 'players/player1.png');

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }
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
      onEnterUpgrades: () {},
      onExitUpgrades: () {},
    )..state = GameState.playing;
    final keyDispatcher = KeyDispatcher();
    add(keyDispatcher);
    final joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
    onGameResize(Vector2.all(Constants.playerSize *
        (Constants.spriteScale + Constants.playerScale) *
        2));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player flashes red when hit', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await Flame.images.loadAll(Assets.explosions);
    await game.onLoad();

    expect(game.player.paint.colorFilter, isNull);

    game.hitPlayer();
    expect(game.player.paint.colorFilter, isNotNull);

    game.update(Constants.playerDamageFlashDuration);
    expect(game.player.paint.colorFilter, isNull);
  });
}
