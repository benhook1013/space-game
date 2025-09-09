@TestOn('browser')
import 'dart:html' as html; // ignore: deprecated_member_use

import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/interaction_web.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onFirstUserInteraction waits for browser event', () async {
    var called = false;
    onFirstUserInteraction(() {
      called = true;
    });

    expect(called, isFalse);

    html.window.dispatchEvent(html.KeyboardEvent('keydown'));
    await Future<void>.delayed(Duration.zero);

    expect(called, isTrue);
  });
}
