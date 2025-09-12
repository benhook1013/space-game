import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/interaction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onFirstUserInteraction invokes callback asynchronously', () async {
    var invoked = false;
    onFirstUserInteraction(() {
      invoked = true;
    });
    expect(invoked, isFalse);

    await Future<void>.delayed(Duration.zero);
    expect(invoked, isTrue);
  });

  test('onFirstUserInteraction surfaces callback errors asynchronously',
      () async {
    final errors = <Object>[];

    runZonedGuarded(() {
      onFirstUserInteraction(() {
        throw StateError('boom');
      });
    }, (error, stack) {
      errors.add(error);
    });

    expect(errors, isEmpty);

    await Future<void>.delayed(Duration.zero);

    expect(errors.single, isA<StateError>());
  });
}
