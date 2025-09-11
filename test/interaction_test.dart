import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/util/interaction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onFirstUserInteraction schedules callback asynchronously on non-web',
      () async {
    var called = false;
    onFirstUserInteraction(() {
      called = true;
    });
    expect(called, isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(called, isTrue);
  });

  test('onFirstUserInteraction executes each callback separately', () async {
    var count = 0;
    onFirstUserInteraction(() {
      count++;
    });
    onFirstUserInteraction(() {
      count++;
    });
    await Future<void>.delayed(Duration.zero);
    expect(count, 2);
  });

  test('onFirstUserInteraction forwards exceptions', () async {
    final errors = <Object>[];
    final completer = Completer<void>();
    runZonedGuarded(() {
      onFirstUserInteraction(() {
        throw Exception('boom');
      });
      Future<void>.delayed(Duration.zero).then((_) => completer.complete());
    }, (error, _) {
      errors.add(error);
    });
    await completer.future;
    expect(errors, hasLength(1));
    expect(errors.first, isException);
  });
}
