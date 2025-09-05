import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/menu_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows high score when non-zero', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.highScore.value = 42;
    await tester.pumpWidget(MaterialApp(home: MenuOverlay(game: game)));
    expect(find.text('High Score: 42'), findsOneWidget);
  });

  testWidgets('player selection updates index', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    await tester.pumpWidget(MaterialApp(home: MenuOverlay(game: game)));

    final imageFinder =
        find.image(AssetImage('assets/images/${Assets.players[1]}'));
    await tester.tap(imageFinder);
    await tester.pump();
    expect(game.selectedPlayerIndex.value, 1);
  });
}
