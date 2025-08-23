import 'package:shared_preferences/shared_preferences.dart';

/// Simple wrapper around [SharedPreferences] for persisting small bits of data.
///
/// Currently only stores and retrieves the local high score but can expand to
/// handle additional settings in the future.
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

  /// Returns the stored high score or `0` if none exists.
  int getHighScore() => _prefs.getInt(_highScoreKey) ?? 0;

  /// Persists a new high score value.
  Future<void> setHighScore(int value) async {
    await _prefs.setInt(_highScoreKey, value);
  }

  /// Whether audio is muted; defaults to `false` if unset.
  bool isMuted() => _prefs.getBool(_mutedKey) ?? false;

  /// Persists the mute flag.
  Future<void> setMuted(bool value) async {
    await _prefs.setBool(_mutedKey, value);
  }
}
