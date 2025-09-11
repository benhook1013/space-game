import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/game/event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('emit delivers events to listeners', () {
    final bus = GameEventBus();
    ComponentSpawnEvent<int>? received;
    bus.on<ComponentSpawnEvent<int>>().listen((e) => received = e);
    bus.emit(ComponentSpawnEvent<int>(5));
    expect(received?.component, 5);
  });

  test('listeners only receive matching types', () {
    final bus = GameEventBus();
    final events = <int>[];
    bus.on<ComponentSpawnEvent<int>>().listen((e) => events.add(e.component));
    bus.emit(ComponentSpawnEvent<int>(1));
    bus.emit(ComponentSpawnEvent<String>('skip'));
    bus.emit(ComponentSpawnEvent<int>(2));
    expect(events, [1, 2]);
  });

  test('base listeners receive all events', () {
    final bus = GameEventBus();
    final events = <GameEvent>[];
    bus.on<GameEvent>().listen(events.add);
    bus.emit(ComponentSpawnEvent<int>(1));
    bus.emit(ComponentRemoveEvent<int>(1));
    expect(events.length, 2);
  });

  test('emit after dispose is ignored', () {
    final bus = GameEventBus();
    final events = <GameEvent>[];
    bus.on<GameEvent>().listen(events.add);
    bus.dispose();
    expect(
      () => bus.emit(ComponentSpawnEvent<int>(1)),
      returnsNormally,
    );
    expect(events, isEmpty);
  });
}
