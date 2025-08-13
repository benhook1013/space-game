import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

/// Central registry for asset paths and preloading.
class Assets {
  static const String player = 'assets/images/player.png';
  static const String enemy = 'assets/images/enemy.png';
  static const String asteroid = 'assets/images/asteroid.png';
  static const String bullet = 'assets/images/bullet.png';

  static const String shootSfx = 'assets/audio/shoot.wav';

  /// Preloads all images and audio assets.
  static Future<void> load() async {
    await Flame.images.loadAll([player, enemy, asteroid, bullet]);

    await FlameAudio.audioCache.loadAll([shootSfx]);
  }
}
