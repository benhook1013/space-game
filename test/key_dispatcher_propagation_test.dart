import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/game/key_dispatcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('KeyDispatcher tracks key state but lets unhandled events propagate',
      () {
    final dispatcher = KeyDispatcher();

    final handledDown = dispatcher.onKeyEvent(
      const KeyDownEvent(
        logicalKey: LogicalKeyboardKey.space,
        physicalKey: PhysicalKeyboardKey.space,
        timeStamp: Duration.zero,
      ),
      {LogicalKeyboardKey.space},
    );
    expect(handledDown, isFalse);
    expect(dispatcher.isPressed(LogicalKeyboardKey.space), isTrue);

    final handledUp = dispatcher.onKeyEvent(
      const KeyUpEvent(
        logicalKey: LogicalKeyboardKey.space,
        physicalKey: PhysicalKeyboardKey.space,
        timeStamp: Duration.zero,
      ),
      <LogicalKeyboardKey>{},
    );
    expect(handledUp, isFalse);
    expect(dispatcher.isPressed(LogicalKeyboardKey.space), isFalse);
  });
}
