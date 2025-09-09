import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/interaction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onFirstUserInteraction invokes callback immediately on non-web', () {
    var called = false;
    onFirstUserInteraction(() {
      called = true;
    });
    expect(called, isTrue);
  });

  test('onFirstUserInteraction executes each callback separately', () {
    var count = 0;
    onFirstUserInteraction(() {
      count++;
    });
    onFirstUserInteraction(() {
      count++;
    });
    expect(count, 2);
  });

  test('onFirstUserInteraction forwards exceptions', () {
    expect(
      () => onFirstUserInteraction(() => throw Exception('boom')),
      throwsException,
    );
  });
}
