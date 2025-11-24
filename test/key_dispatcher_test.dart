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

    group('unhandled key events', () {
      const keyDownSpace = KeyDownEvent(
        logicalKey: LogicalKeyboardKey.space,
        physicalKey: PhysicalKeyboardKey.space,
        timeStamp: Duration.zero,
      );

      final scenarios = <({String description, void Function() run})>[
        (
          description: 'ignored keys are not consumed',
          run: () {
            final dispatcher = KeyDispatcher();
            dispatcher.unregister(LogicalKeyboardKey.space);
            final result = dispatcher.onKeyEvent(
              keyDownSpace,
              {LogicalKeyboardKey.space},
            );
            expect(result, isFalse);
          },
        ),
        (
          description: 'unhandled keys propagate',
          run: () {
            final dispatcher = KeyDispatcher();
            final result = dispatcher.onKeyEvent(
              keyDownSpace,
              {LogicalKeyboardKey.space},
            );
            expect(result, isFalse);
          },
        ),
      ];

      for (final scenario in scenarios) {
        test(scenario.description, scenario.run);
      }

      test('tracks pressed state for unhandled keys', () {
        final dispatcher = KeyDispatcher();
        final handledDown = dispatcher.onKeyEvent(
          keyDownSpace,
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

    test('register with no callbacks leaves key unhandled', () {
      final dispatcher = KeyDispatcher();
      dispatcher.register(LogicalKeyboardKey.space);
      final handled = dispatcher.onKeyEvent(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.space,
          physicalKey: PhysicalKeyboardKey.space,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.space},
      );
      expect(handled, isFalse);
    });

    test('multiple callbacks for a key all fire', () {
      final dispatcher = KeyDispatcher();
      var count = 0;
      dispatcher.register(
        LogicalKeyboardKey.space,
        onDown: () => count++,
      );
      dispatcher.register(
        LogicalKeyboardKey.space,
        onDown: () => count++,
      );
      dispatcher.onKeyEvent(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.space,
          physicalKey: PhysicalKeyboardKey.space,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.space},
      );
      expect(count, 2);
    });
  });
}
