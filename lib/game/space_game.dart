import 'package:flame/game.dart';
import '../assets.dart';
import 'game_state.dart';

/// Root Flame game handling the core loop.
class SpaceGame extends FlameGame {
  GameState state = GameState.menu;

  @override
  Future<void> onLoad() async {
    await Assets.load();
  }
}
