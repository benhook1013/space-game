import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/settings_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('slider and toggle modify settings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final view = tester.view;
    view.physicalSize = const Size(800, 1200);
    view.devicePixelRatio = 1;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    await tester.pumpWidget(MaterialApp(home: SettingsOverlay(game: game)));

    final slider = find.byType(Slider).first;
    final initial = game.settingsService.hudButtonScale.value;
    await tester.drag(slider, const Offset(50, 0));
    await tester.pump();
    expect(game.settingsService.hudButtonScale.value, isNot(initial));

    final minimapSlider = find.byType(Slider).at(3);
    final minimapInitial = game.settingsService.minimapScale.value;
    await tester.drag(minimapSlider, const Offset(50, 0));
    await tester.pump();
    expect(game.settingsService.minimapScale.value, isNot(minimapInitial));

    final toggle = find.byType(Switch);
    expect(game.settingsService.muteOnPause.value, isTrue);
    await tester.tap(toggle, warnIfMissed: false);
    await tester.pump();
    expect(game.settingsService.muteOnPause.value, isFalse);
  });
}
