import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/components/player.dart';
import 'package:space_game/game/control_manager.dart';
import 'package:space_game/game/key_dispatcher.dart';
import 'package:space_game/services/settings_service.dart';

import 'test_joystick.dart';

class _TestPlayer extends PlayerComponent {
  _TestPlayer()
      : super(
          joystick: TestJoystick(),
          keyDispatcher: KeyDispatcher(),
          spritePath: '',
        );

  bool started = false;
  bool stopped = false;

  @override
  Future<void> onLoad() async {}

  @override
  void startShooting() {
    started = true;
  }

  @override
  void stopShooting() {
    stopped = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('attachPlayer adds fire button and hooks callbacks', () async {
    final game = FlameGame();
    final settings = SettingsService();
    final control = ControlManager(
      game: game,
      settings: settings,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
    await control.init();

    final player = _TestPlayer();
    await control.attachPlayer(player);

    expect(control.fireButton, isNotNull);
    expect(control.fireButton!.parent, equals(game));

    control.fireButton!.onPressed?.call();
    control.fireButton!.onReleased?.call();
    expect(player.started, isTrue);
    expect(player.stopped, isTrue);
  });

  test('dispose removes listeners and control components', () async {
    final game = FlameGame();
    final settings = SettingsService();
    final control = ControlManager(
      game: game,
      settings: settings,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
    await control.init();
    final player = _TestPlayer();
    await control.attachPlayer(player);

    settings.joystickScale.value = 2;
    final bg = control.joystick.background as CircleComponent;
    final fire = control.fireButton!.button as CircleComponent;
    expect(bg.radius, 100);

    control.dispose();
    expect(control.joystick.parent, isNull);
    expect(control.fireButton!.parent, isNull);

    final oldBgRadius = bg.radius;
    final oldFireRadius = fire.radius;
    settings.joystickScale.value = 3;

    expect(bg.radius, oldBgRadius);
    expect(fire.radius, oldFireRadius);
  });
}
