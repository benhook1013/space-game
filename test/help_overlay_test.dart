import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/game/game_state.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/help_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggleHelp pauses and resumes the game', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.overlays.addEntry(HelpOverlay.id, (_, __) => const SizedBox());

    game.state = GameState.playing;
    expect(game.overlays.isActive(HelpOverlay.id), isFalse);
    expect(game.paused, isFalse);

    game.toggleHelp();
    expect(game.overlays.isActive(HelpOverlay.id), isTrue);
    expect(game.paused, isTrue);

    game.toggleHelp();
    expect(game.overlays.isActive(HelpOverlay.id), isFalse);
    expect(game.paused, isFalse);
  });
}
