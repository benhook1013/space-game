import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:space_game/constants.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/theme/star_palette.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/settings_overlay.dart';
import 'package:space_game/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reset restores settings and audio defaults', (tester) async {
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
    final settings = game.settingsService;
    settings.hudButtonScale.value = 1.2;
    settings.minimapScale.value = 1.3;
    settings.textScale.value = 1.8;
    settings.joystickScale.value = 1.4;
    settings.targetingRange.value = 400;
    settings.tractorRange.value = 300;
    settings.miningRange.value = 200;
    settings.starfieldTileSize.value = 768;
    settings.starfieldDensity.value = 1.5;
    settings.starfieldBrightness.value = 0.5;
    settings.starfieldGamma.value = 1.8;
    settings.starfieldPalette.value = StarPalette.dusk;
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

    expect(settings.hudButtonScale.value, SettingsService.defaultHudButtonScale);
    expect(settings.minimapScale.value, SettingsService.defaultMinimapScale);
    expect(settings.textScale.value, SettingsService.defaultTextScale);
    expect(settings.joystickScale.value, SettingsService.defaultJoystickScale);
    expect(settings.targetingRange.value, Constants.playerAutoAimRange);
    expect(settings.tractorRange.value, Constants.playerTractorAuraRadius);
    expect(settings.miningRange.value, Constants.playerMiningRange);
    expect(settings.starfieldTileSize.value, Constants.starfieldTileSize);
    expect(settings.starfieldDensity.value, Constants.starfieldDensity);
    expect(settings.starfieldBrightness.value, Constants.starfieldBrightness);
    expect(settings.starfieldGamma.value, Constants.starfieldGamma);
    expect(settings.starfieldPalette.value, StarPalette.classic);
    expect(audio.masterVolume, 1);
  });
}
