import 'package:shared_preferences/shared_preferences.dart';

/// Simple wrapper around [SharedPreferences] for persisting small bits of data.
///
/// Stores the local high score, mute flag and selected player sprite index.
/// Additional getters/setters expose primitive types for future expansion.
class StorageService {
  StorageService(this._prefs);

  /// Asynchronously create a [StorageService] instance.
  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  final SharedPreferences _prefs;

  static const _highScoreKey = 'highScore';
  static const _mutedKey = 'muted';
  static const _playerSpriteKey = 'playerSpriteIndex';

  /// Returns the stored high score or `0` if none exists.
  int getHighScore() => _prefs.getInt(_highScoreKey) ?? 0;

  /// Persists a new high score value.
  Future<void> setHighScore(int value) async {
    await _prefs.setInt(_highScoreKey, value);
  }

  /// Clears the stored high score.
  Future<void> resetHighScore() async {
    await _prefs.remove(_highScoreKey);
  }

  /// Whether audio is muted; defaults to `false` if unset.
  bool isMuted() => _prefs.getBool(_mutedKey) ?? false;

  /// Persists the mute flag.
  Future<void> setMuted(bool value) async {
    await _prefs.setBool(_mutedKey, value);
  }

  /// Returns the selected player sprite index or `0` if unset.
  int getPlayerSpriteIndex() => _prefs.getInt(_playerSpriteKey) ?? 0;

  /// Persists the selected player sprite index.
  Future<void> setPlayerSpriteIndex(int value) async {
    await _prefs.setInt(_playerSpriteKey, value);
  }

  /// Retrieves a double value for [key] or returns [defaultValue] if unset.
  double getDouble(String key, double defaultValue) =>
      _prefs.getDouble(key) ?? defaultValue;

  /// Persists a double [value] for [key].
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  /// Retrieves a boolean for [key] or returns [defaultValue] if unset.
  bool getBool(String key, bool defaultValue) =>
      _prefs.getBool(key) ?? defaultValue;

  /// Persists a boolean [value] for [key].
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Retrieves an integer for [key] or returns [defaultValue] if unset.
  int getInt(String key, int defaultValue) =>
      _prefs.getInt(key) ?? defaultValue;

  /// Persists an integer [value] for [key].
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }
}
