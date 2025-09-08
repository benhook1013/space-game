import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/game/event_bus.dart';
import 'package:space_game/services/targeting_service.dart';
import 'package:space_game/components/player.dart';
import 'package:space_game/game/key_dispatcher.dart';

import 'test_joystick.dart';

class _DummyPlayer extends PlayerComponent {
  _DummyPlayer()
      : super(
          joystick: TestJoystick(),
          keyDispatcher: KeyDispatcher(),
          spritePath: 'dummy.png',
        );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tracks player spawn and removal', () {
    final bus = GameEventBus();
    final targeting = TargetingService(bus);
    final player = _DummyPlayer()..position = Vector2(1, 2);

    bus.emit(ComponentSpawnEvent<PlayerComponent>(player));
    expect(targeting.playerPosition, player.position);

    bus.emit(ComponentRemoveEvent<PlayerComponent>(player));
    expect(targeting.playerPosition, isNull);
    targeting.dispose();
    bus.dispose();
  });

  test('disposing cancels event subscriptions', () {
    final bus = GameEventBus();
    final targeting = TargetingService(bus);
    final player = _DummyPlayer()..position = Vector2.zero();

    bus.emit(ComponentSpawnEvent<PlayerComponent>(player));
    expect(targeting.playerPosition, player.position);

    targeting.dispose();

    // After disposal, further events should have no effect.
    bus.emit(ComponentRemoveEvent<PlayerComponent>(player));
    expect(targeting.playerPosition, player.position);

    final newPlayer = _DummyPlayer()..position = Vector2(5, 6);
    bus.emit(ComponentSpawnEvent<PlayerComponent>(newPlayer));
    expect(targeting.playerPosition, player.position);

    bus.dispose();
  });
}
