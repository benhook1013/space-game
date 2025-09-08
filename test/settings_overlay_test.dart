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

  testWidgets('slider modifies settings', (tester) async {
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
    final initial = audio.masterVolume;
    await tester.drag(slider, const Offset(50, 0));
    await tester.pump();
    expect(audio.masterVolume, isNot(initial));
  });

  testWidgets('reset button restores defaults', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final view = tester.view;
    view.physicalSize = const Size(800, 1200);
    view.devicePixelRatio = 1;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    final storage = await StorageService.create();
    final audio = await AudioService.create(storage);
    final game = SpaceGame(storageService: storage, audioService: audio);
    game.settingsService.hudButtonScale.value = 1.2;
    audio.setMasterVolume(0.5);

    await tester.pumpWidget(MaterialApp(home: SettingsOverlay(game: game)));
    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(game.settingsService.hudButtonScale.value,
        SettingsService.defaultHudButtonScale);
    expect(audio.masterVolume, 1);
  });
}
