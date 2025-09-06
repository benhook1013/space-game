import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('image assets load and can be loaded twice', () async {
    await Flame.images.loadAll([...Assets.players, Assets.bullet]);
    await Flame.images.loadAll([...Assets.players, Assets.bullet]);
    expect(() => Flame.images.fromCache(Assets.bullet), returnsNormally);
  });

  test('loading a missing image throws FlutterError', () async {
    await expectLater(
      Flame.images.load('missing.png'),
      throwsA(isA<FlutterError>()),
    );
  });
}
