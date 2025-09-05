import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/game/event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('emit delivers events to listeners', () {
    final bus = GameEventBus();
    var received = 0;
    bus.on<int>().listen((e) => received = e);
    bus.emit(5);
    expect(received, 5);
  });

  test('listeners only receive matching types', () {
    final bus = GameEventBus();
    final events = <int>[];
    bus.on<int>().listen(events.add);
    bus.emit(1);
    bus.emit('not int');
    bus.emit(2);
    expect(events, [1, 2]);
  });
}
