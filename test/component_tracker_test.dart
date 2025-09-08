import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/util/component_tracker.dart';
import 'package:space_game/game/event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tracks component spawn and removal', () {
    final bus = GameEventBus();
    final tracker = ComponentTracker<PositionComponent>(bus);
    final component = PositionComponent();

    bus.emit(ComponentSpawnEvent<PositionComponent>(component));
    expect(tracker.component, component);

    bus.emit(ComponentRemoveEvent<PositionComponent>(component));
    expect(tracker.component, isNull);

    tracker.dispose();
    bus.dispose();
  });

  test('disposing stops tracking further events', () {
    final bus = GameEventBus();
    final tracker = ComponentTracker<PositionComponent>(bus);
    final component = PositionComponent();

    bus.emit(ComponentSpawnEvent<PositionComponent>(component));
    expect(tracker.component, component);

    tracker.dispose();

    bus.emit(ComponentRemoveEvent<PositionComponent>(component));
    expect(tracker.component, component);

    bus.dispose();
  });
}
