import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:space_game/assets.dart';

class _FakeAudioCache extends AudioCache {
  @override
  Future<Uri> load(String file) async => Uri();

  @override
  Future<void> clearAll() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('asset loaders can be called multiple times and missing asset throws',
      () async {
    Flame.images.clearCache();
    FlameAudio.audioCache = _FakeAudioCache();

    await Assets.loadEssential();
    await Assets.loadEssential();
    await Assets.loadRemaining();
    await Assets.loadRemaining();

    expect(
      () => Flame.images.fromCache('does_not_exist.png'),
      throwsA(isA<AssertionError>()),
    );
  });
}
