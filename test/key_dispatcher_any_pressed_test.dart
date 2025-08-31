import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/game/key_dispatcher.dart';

void main() {
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
}
