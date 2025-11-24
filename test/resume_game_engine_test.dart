import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/lifecycle_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resumeGame resumes engine after external pause', () async {
    SharedPreferences.setMockInitialValues({});
    await loadLifecycleTestImages();
    final game = await createLifecycleTestGame(
      includeHudOverlay: true,
      includePauseOverlay: true,
    );
    await game.startGame();
    await game.ready();

    game.pauseGame();
    expect(game.paused, isFalse);

    game.pauseEngine();
    expect(game.paused, isTrue);

    game.resumeGame();
    expect(game.paused, isFalse);
  });
}
