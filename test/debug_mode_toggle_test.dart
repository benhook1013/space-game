import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toggleDebug switches debugMode', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    expect(game.debugMode, isTrue);
    game.toggleDebug();
    expect(game.debugMode, isFalse);
    game.toggleDebug();
    expect(game.debugMode, isTrue);
  });
}
