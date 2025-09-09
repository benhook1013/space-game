import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/game/event_bus.dart';

class _IntEvent implements GameEvent {
  _IntEvent(this.value);
  final int value;
}

class _OtherEvent implements GameEvent {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('emit delivers events to listeners', () {
    final bus = GameEventBus();
    var received = 0;
    bus.on<_IntEvent>().listen((e) => received = e.value);
    bus.emit(_IntEvent(5));
    expect(received, 5);
  });

  test('listeners only receive matching types', () {
    final bus = GameEventBus();
    final events = <int>[];
    bus.on<_IntEvent>().listen((e) => events.add(e.value));
    bus.emit(_IntEvent(1));
    bus.emit(_OtherEvent());
    bus.emit(_IntEvent(2));
    expect(events, [1, 2]);
  });
}
