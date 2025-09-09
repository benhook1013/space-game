@TestOn('browser')
import 'package:web/web.dart' as web;

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

    web.window.dispatchEvent(web.KeyboardEvent('keydown'));
    await Future<void>.delayed(Duration.zero);

    expect(called, isTrue);
  });
}
