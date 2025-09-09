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
}
