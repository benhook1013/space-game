import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/game/key_dispatcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeyDispatcher', () {
    test('onKeyEvent consumes handled keys', () {
      final dispatcher = KeyDispatcher();
      var pressed = false;
      dispatcher.register(
        LogicalKeyboardKey.space,
        onDown: () => pressed = true,
      );
      final result = dispatcher.onKeyEvent(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.space,
          physicalKey: PhysicalKeyboardKey.space,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.space},
      );
      expect(pressed, isTrue);
      expect(result, isTrue);
    });

    test('ignored keys are not consumed', () {
      final dispatcher = KeyDispatcher();
      dispatcher.unregister(LogicalKeyboardKey.space);
      final result = dispatcher.onKeyEvent(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.space,
          physicalKey: PhysicalKeyboardKey.space,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.space},
      );
      expect(result, isFalse);
    });

    test('unhandled keys propagate', () {
      final dispatcher = KeyDispatcher();
      final result = dispatcher.onKeyEvent(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.space,
          physicalKey: PhysicalKeyboardKey.space,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.space},
      );
      expect(result, isFalse);
    });

    test('tracks pressed state for unhandled keys', () {
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

    test('isAnyPressed reports true when any key is pressed', () {
      final dispatcher = KeyDispatcher();
      dispatcher.onKeyEvent(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyA},
      );
      expect(
        dispatcher.isAnyPressed([
          LogicalKeyboardKey.keyA,
          LogicalKeyboardKey.keyB,
        ]),
        isTrue,
      );
    });

    test('isAnyPressed reports false when none of the keys are pressed', () {
      final dispatcher = KeyDispatcher();
      dispatcher.onKeyEvent(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyA},
      );
      dispatcher.onKeyEvent(
        const KeyUpEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
        <LogicalKeyboardKey>{},
      );
      expect(
        dispatcher.isAnyPressed([
          LogicalKeyboardKey.keyA,
          LogicalKeyboardKey.keyB,
        ]),
        isFalse,
      );
    });
  });
}
