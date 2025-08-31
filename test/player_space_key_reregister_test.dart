import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/components/player.dart';
import 'package:space_game/game/key_dispatcher.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer({required super.joystick, required super.keyDispatcher})
      : super(spritePath: 'players/player1.png');

  bool started = false;

  @override
  void startShooting() {
    started = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player re-registers space key after remount', () async {
    final keyDispatcher = KeyDispatcher();
    final joystick = JoystickComponent(
      knob: CircleComponent(radius: 1),
      background: CircleComponent(radius: 2),
    );
    final player = _TestPlayer(
      joystick: joystick,
      keyDispatcher: keyDispatcher,
    );

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, 1, 1), Paint()..color = const Color(0xffffffff));
    final image = await recorder.endRecording().toImage(1, 1);
    Flame.images.add('players/player1.png', image);
    await player.onLoad();

    player.onMount();
    player.onRemove();
    player.onMount();

    keyDispatcher.onKeyEvent(
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
