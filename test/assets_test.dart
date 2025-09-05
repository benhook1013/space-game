import 'package:audioplayers/audioplayers.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Assets.load', () {
    setUp(() {
      Flame.images.clearCache();
      Flame.images.prefix = 'assets/images/';
      FlameAudio.audioCache = _StubAudioCache();
    });

    test('preloads images and is idempotent', () async {
      await Assets.load();
      final initialCount = Flame.images.keys.length;
      expect(initialCount, greaterThan(0));
      expect(Flame.images.containsKey(Assets.players.first), isTrue);

      await Assets.load();
      expect(Flame.images.keys.length, initialCount);
    });

    test('fromCache throws for missing image', () {
      expect(
        () => Flame.images.fromCache('does_not_exist.png'),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

class _StubAudioCache extends AudioCache {
  _StubAudioCache() : super(prefix: '');

  @override
  Future<List<Uri>> loadAll(List<String> files) async => [];
}
