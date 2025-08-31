import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/game/key_dispatcher.dart';

void main() {
  test('KeyDispatcher does not consume events', () {
    final dispatcher = KeyDispatcher();
    final event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.space,
      physicalKey: PhysicalKeyboardKey.space,
      timeStamp: Duration.zero,
    );
    final handled = dispatcher.onKeyEvent(event, {LogicalKeyboardKey.space});
    expect(handled, isFalse);
  });
}
