import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults are set and notifiers update', () {
    final settings = SettingsService();

    expect(
        settings.hudButtonScale.value, SettingsService.defaultHudButtonScale);
    expect(settings.textScale.value, SettingsService.defaultTextScale);
    expect(settings.joystickScale.value, SettingsService.defaultJoystickScale);
    expect(settings.targetingRange.value, Constants.playerAutoAimRange);
    expect(settings.tractorRange.value, Constants.playerTractorAuraRadius);
    expect(settings.miningRange.value, Constants.playerMiningRange);

    var hudNotified = false;
    settings.hudButtonScale.addListener(() {
      hudNotified = true;
    });
    settings.hudButtonScale.value = 1.2;
    expect(hudNotified, isTrue);
    expect(settings.hudButtonScale.value, 1.2);
  });
}
