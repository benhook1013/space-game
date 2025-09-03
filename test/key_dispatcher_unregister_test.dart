import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/game/key_dispatcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('unregister removes callbacks and pressed state', () {
    final dispatcher = KeyDispatcher();
    var count = 0;
    dispatcher.register(
      LogicalKeyboardKey.space,
      onDown: () {
        count++;
      },
    );
    dispatcher.onKeyEvent(
      const KeyDownEvent(
        logicalKey: LogicalKeyboardKey.space,
        physicalKey: PhysicalKeyboardKey.space,
        timeStamp: Duration.zero,
      ),
      {LogicalKeyboardKey.space},
    );
    dispatcher.unregister(LogicalKeyboardKey.space);
    dispatcher.onKeyEvent(
      const KeyDownEvent(
        logicalKey: LogicalKeyboardKey.space,
        physicalKey: PhysicalKeyboardKey.space,
        timeStamp: Duration.zero,
      ),
      {LogicalKeyboardKey.space},
    );
    expect(count, 1);
    expect(dispatcher.isPressed(LogicalKeyboardKey.space), isFalse);
  });
}
