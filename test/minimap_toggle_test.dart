import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';

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
    final keyDispatcher = KeyDispatcher();
    add(keyDispatcher);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    player = _TestPlayer(joystick: joystick, keyDispatcher: keyDispatcher);
    await add(player);
    onGameResize(
      Vector2.all(Constants.playerSize *
          (Constants.spriteScale + Constants.playerScale) *
          2),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggle minimap visibility', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();

    expect(game.showMinimap.value, isTrue);
    game.toggleMinimap();
    expect(game.showMinimap.value, isFalse);
    game.toggleMinimap();
    expect(game.showMinimap.value, isTrue);
  });
}
