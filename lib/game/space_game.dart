import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart' show EdgeInsets;

import '../assets.dart';
import '../components/player.dart';
import 'game_state.dart';

/// Root Flame game handling the core loop.
class SpaceGame extends FlameGame with HasKeyboardHandlerComponents {
  GameState state = GameState.menu;
  late final PlayerComponent player;
  late final JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    await Assets.load();
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 20,
        paint: Paint()..color = const Color(0xffffffff),
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = const Color(0x66ffffff),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);

    player = PlayerComponent(joystick: joystick);
    add(player);
  }
}
