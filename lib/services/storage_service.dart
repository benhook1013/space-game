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

  /// Retrieves a stored value for [key] or returns [defaultValue] if unset.
  ///
  /// Supported types are [int], [double], [bool], [String] and
  /// [List]<[String]>. Throws [UnsupportedError] for unsupported types.
  T getValue<T>(String key, T defaultValue) {
    final value = _prefs.get(key);
    return value is T ? value : defaultValue;
  }

  /// Persists [value] for [key].
  ///
  /// Supported types are [int], [double], [bool], [String] and
  /// [List]<[String]>. Throws [UnsupportedError] for unsupported types.
  Future<void> setValue<T>(String key, T value) async {
    if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      throw UnsupportedError('Type ${value.runtimeType} is not supported');
    }
  }

  /// Returns the stored high score or `0` if none exists.
  int getHighScore() => getInt(_highScoreKey, 0);

  /// Persists a new high score value.
  Future<void> setHighScore(int value) => setInt(_highScoreKey, value);

  /// Clears the stored high score.
  Future<void> resetHighScore() async => _prefs.remove(_highScoreKey);

  /// Whether audio is muted; defaults to `false` if unset.
  bool isMuted() => getBool(_mutedKey, false);

  /// Persists the mute flag.
  Future<void> setMuted(bool value) => setBool(_mutedKey, value);

  /// Returns the selected player sprite index or `0` if unset.
  int getPlayerSpriteIndex() => getInt(_playerSpriteKey, 0);

  /// Persists the selected player sprite index.
  Future<void> setPlayerSpriteIndex(int value) =>
      setInt(_playerSpriteKey, value);

  /// Retrieves a double value for [key] or returns [defaultValue] if unset.
  double getDouble(String key, double defaultValue) =>
      getValue<double>(key, defaultValue);

  /// Persists a double [value] for [key].
  Future<void> setDouble(String key, double value) =>
      setValue<double>(key, value);

  /// Retrieves a boolean for [key] or returns [defaultValue] if unset.
  bool getBool(String key, bool defaultValue) =>
      getValue<bool>(key, defaultValue);

  /// Persists a boolean [value] for [key].
  Future<void> setBool(String key, bool value) => setValue<bool>(key, value);

  /// Retrieves an integer for [key] or returns [defaultValue] if unset.
  int getInt(String key, int defaultValue) => getValue<int>(key, defaultValue);

  /// Persists an integer [value] for [key].
  Future<void> setInt(String key, int value) => setValue<int>(key, value);

  /// Retrieves a string for [key] or returns [defaultValue] if unset.
  String getString(String key, String defaultValue) =>
      getValue<String>(key, defaultValue);

  /// Persists a string [value] for [key].
  Future<void> setString(String key, String value) =>
      setValue<String>(key, value);

  /// Retrieves a list of strings for [key] or returns [defaultValue] if unset.
  List<String> getStringList(String key, List<String> defaultValue) =>
      getValue<List<String>>(key, defaultValue);

  /// Persists a list of strings [value] for [key].
  Future<void> setStringList(String key, List<String> value) =>
      setValue<List<String>>(key, value);
}
