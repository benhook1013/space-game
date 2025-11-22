import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/ui/help_overlay.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows controls help content', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: HelpOverlay(game: game),
    ));

    expect(find.text('Controls'), findsOneWidget);
    expect(find.textContaining('Move: WASD / Arrow keys'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}
