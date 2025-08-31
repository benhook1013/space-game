import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/game/key_dispatcher.dart';

void main() {
  test('onKeyEvent consumes handled keys', () {
    final dispatcher = KeyDispatcher();
    var pressed = false;
    dispatcher.register(
      LogicalKeyboardKey.space,
      onDown: () => pressed = true,
    );
    final result = dispatcher.onKeyEvent(
      KeyDownEvent(
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
      KeyDownEvent(
        logicalKey: LogicalKeyboardKey.space,
        physicalKey: PhysicalKeyboardKey.space,
        timeStamp: Duration.zero,
      ),
      {LogicalKeyboardKey.space},
    );
    expect(result, isFalse);
  });
}
