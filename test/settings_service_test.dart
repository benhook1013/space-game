import 'package:flutter_test/flutter_test.dart';
import 'package:space_game/constants.dart';
import 'package:space_game/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults are set', () {
    final settings = SettingsService();

    expect(
        settings.hudButtonScale.value, SettingsService.defaultHudButtonScale);
    expect(settings.textScale.value, SettingsService.defaultTextScale);
    expect(settings.joystickScale.value, SettingsService.defaultJoystickScale);
    expect(settings.targetingRange.value, Constants.playerAutoAimRange);
    expect(settings.tractorRange.value, Constants.playerTractorAuraRadius);
    expect(settings.miningRange.value, Constants.playerMiningRange);
  });

  test('notifiers update when values change', () {
    final settings = SettingsService();

    var hudNotified = false;
    var textNotified = false;
    var joystickNotified = false;
    var targetingNotified = false;
    var tractorNotified = false;
    var miningNotified = false;

    settings.hudButtonScale.addListener(() => hudNotified = true);
    settings.textScale.addListener(() => textNotified = true);
    settings.joystickScale.addListener(() => joystickNotified = true);
    settings.targetingRange.addListener(() => targetingNotified = true);
    settings.tractorRange.addListener(() => tractorNotified = true);
    settings.miningRange.addListener(() => miningNotified = true);

    settings.hudButtonScale.value = 1.2;
    settings.textScale.value = 1.3;
    settings.joystickScale.value = 1.1;
    settings.targetingRange.value = 350;
    settings.tractorRange.value = 250;
    settings.miningRange.value = 180;

    expect(hudNotified, isTrue);
    expect(textNotified, isTrue);
    expect(joystickNotified, isTrue);
    expect(targetingNotified, isTrue);
    expect(tractorNotified, isTrue);
    expect(miningNotified, isTrue);

    expect(settings.hudButtonScale.value, 1.2);
    expect(settings.textScale.value, 1.3);
    expect(settings.joystickScale.value, 1.1);
    expect(settings.targetingRange.value, 350);
    expect(settings.tractorRange.value, 250);
    expect(settings.miningRange.value, 180);
  });
}
