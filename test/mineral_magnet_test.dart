import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/components/mineral_magnet.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/constants.dart';

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
    player = PlayerComponent(
      joystick: joystick,
      keyDispatcher: keyDispatcher,
      spritePath: 'players/player1.png',
    );
    add(player);
    mineralMagnet = MineralMagnetComponent(player: player);
    add(mineralMagnet);
    onGameResize(
      Vector2.all(Constants.playerSize *
          (Constants.spriteScale + Constants.playerScale) *
          2),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('minerals move toward player within magnet field', () async {
    SharedPreferences.setMockInitialValues({});
    await Flame.images.loadAll([Assets.mineralIcon, ...Assets.players]);
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = _TestGame(storage: storage, audio: audio);
    await game.onLoad();

    final mineral = game.acquireMineral(game.player.position + Vector2(100, 0));
    game.mineralPickups.add(mineral);
    await game.add(mineral);
    game.update(0);

    final initial = (game.player.position - mineral.position).length;
    game.update(0.1);
    final current = (game.player.position - mineral.position).length;

    expect(current, lessThan(initial));
  });
}
