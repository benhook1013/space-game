import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../theme/star_palette.dart';
import 'storage_service.dart';

/// Holds tweakable UI scale values, gameplay ranges and performance tweaks for
/// live prototyping.
class SettingsService {
  SettingsService({StorageService? storage}) : _storage = storage {
    _notifiers = _settingDefaults.map(
        (key, defaultValue) => MapEntry(key, _initNotifier(key, defaultValue)));

    hudButtonScale = _notifiers[_hudScaleKey]!;
    textScale = _notifiers[_textScaleKey]!;
    joystickScale = _notifiers[_joystickScaleKey]!;
    minimapScale = _notifiers[_minimapScaleKey]!;
    targetingRange = _notifiers[_targetingRangeKey]!;
    tractorRange = _notifiers[_tractorRangeKey]!;
    miningRange = _notifiers[_miningRangeKey]!;
    starfieldTileSize = _notifiers[_starfieldTileSizeKey]!;
    starfieldDensity = _notifiers[_starfieldDensityKey]!;
    starfieldBrightness = _notifiers[_starfieldBrightnessKey]!;
    starfieldGamma = _notifiers[_starfieldGammaKey]!;
    final paletteIndex = _safePaletteIndex(
      _storage?.getInt(_starfieldPaletteKey, 0) ?? 0,
    );
    starfieldPalette =
        ValueNotifier<StarPalette>(StarPalette.values[paletteIndex]);
    starfieldPalette.addListener(() =>
        _storage?.setInt(_starfieldPaletteKey, starfieldPalette.value.index));
  }

  static const double defaultHudButtonScale = 0.75;
  static const double defaultTextScale = 1.5;
  static const double defaultJoystickScale = 1;
  static const double defaultMinimapScale = 1;

  /// Multiplier applied to HUD buttons and icons.
  late final ValueNotifier<double> hudButtonScale;

  /// Multiplier applied to in-game text sizes.
  late final ValueNotifier<double> textScale;

  /// Multiplier applied to on-screen joystick elements.
  late final ValueNotifier<double> joystickScale;

  /// Multiplier applied to the minimap size.
  late final ValueNotifier<double> minimapScale;

  /// Distance used to auto-aim enemies when stationary.
  late final ValueNotifier<double> targetingRange;

  /// Radius of the player's Tractor Aura in pixels.
  late final ValueNotifier<double> tractorRange;

  /// Maximum distance to auto-mine asteroids, in pixels.
  late final ValueNotifier<double> miningRange;

  /// Size of each generated starfield tile.
  late final ValueNotifier<double> starfieldTileSize;

  /// Global multiplier applied to star density.
  late final ValueNotifier<double> starfieldDensity;

  /// Global multiplier applied to star brightness.
  late final ValueNotifier<double> starfieldBrightness;

  /// Exponent applied to star brightness.
  late final ValueNotifier<double> starfieldGamma;

  /// Currently selected star colour palette.
  late final ValueNotifier<StarPalette> starfieldPalette;

  StorageService? _storage;
  late final Map<String, ValueNotifier<double>> _notifiers;

  /// Attaches a [StorageService] after construction and loads any persisted
  /// values into the existing notifiers. If storage has already been provided,
  /// this call is ignored.
  void attachStorage(StorageService storage) {
    if (_storage != null) {
      return;
    }
    _storage = storage;
    _notifiers.forEach(
      (key, notifier) =>
          notifier.value = storage.getDouble(key, notifier.value),
    );
    final paletteIndex =
        _safePaletteIndex(storage.getInt(_starfieldPaletteKey, 0));
    starfieldPalette.value = StarPalette.values[paletteIndex];
  }

  /// Restores all values to their defaults.
  void reset() {
    _settingDefaults.forEach(
      (key, defaultValue) => _notifiers[key]!.value = defaultValue,
    );
    starfieldPalette.value = StarPalette.classic;
  }

  static const _hudScaleKey = 'hudButtonScale';
  static const _textScaleKey = 'textScale';
  static const _joystickScaleKey = 'joystickScale';
  static const _minimapScaleKey = 'minimapScale';
  static const _targetingRangeKey = 'targetingRange';
  static const _tractorRangeKey = 'tractorRange';
  static const _miningRangeKey = 'miningRange';
  static const _starfieldTileSizeKey = 'starfieldTileSize';
  static const _starfieldDensityKey = 'starfieldDensity';
  static const _starfieldBrightnessKey = 'starfieldBrightness';
  static const _starfieldGammaKey = 'starfieldGamma';
  static const _starfieldPaletteKey = 'starfieldPalette';

  static const _settingDefaults = <String, double>{
    _hudScaleKey: defaultHudButtonScale,
    _textScaleKey: defaultTextScale,
    _joystickScaleKey: defaultJoystickScale,
    _minimapScaleKey: defaultMinimapScale,
    _targetingRangeKey: Constants.playerAutoAimRange,
    _tractorRangeKey: Constants.playerTractorAuraRadius,
    _miningRangeKey: Constants.playerMiningRange,
    _starfieldTileSizeKey: Constants.starfieldTileSize,
    _starfieldDensityKey: Constants.starfieldDensity,
    _starfieldBrightnessKey: Constants.starfieldBrightness,
    _starfieldGammaKey: Constants.starfieldGamma,
  };

  ValueNotifier<double> _initNotifier(String key, double defaultValue) {
    final value = _storage?.getDouble(key, defaultValue) ?? defaultValue;
    final notifier =
        ValueNotifier<double>(value.isFinite ? value : defaultValue);
    notifier.addListener(() => _storage?.setDouble(key, notifier.value));
    return notifier;
  }

  int _safePaletteIndex(int index) {
    if (index < 0 || index >= StarPalette.values.length) {
      return 0;
    }
    return index;
  }

  /// Releases resources held by the service.
  void dispose() {
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    starfieldPalette.dispose();
    _notifiers.clear();
  }
}
