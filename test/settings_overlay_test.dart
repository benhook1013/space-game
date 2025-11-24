import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/settings_overlay.dart';
import 'package:space_game/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('controls update settings and reset restores defaults',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final view = tester.view;
    view.physicalSize = const Size(800, 1200);
    view.devicePixelRatio = 1;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);

    // Start with non-default values so we can verify reset restores them.
    game.settingsService.hudButtonScale.value = 1.2;
    audio.setMasterVolume(0.5);

    await tester.pumpWidget(MaterialApp(home: SettingsOverlay(game: game)));

    // Adjust the volume slider to ensure controls apply changes.
    final slider = find.byType(Slider).first;
    await tester.drag(slider, const Offset(50, 0));
    await tester.pump();
    expect(audio.masterVolume, isNot(0.5));

    await tester.ensureVisible(find.text('Reset'));
    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(game.settingsService.hudButtonScale.value,
        SettingsService.defaultHudButtonScale);
    expect(audio.masterVolume, 1);
  });
}
