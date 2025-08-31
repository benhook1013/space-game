import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../assets.dart';
import '../constants.dart';

/// Short-lived animation played when a ship is destroyed.
class ExplosionComponent extends SpriteAnimationComponent {
  ExplosionComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(
            Constants.explosionSize *
                (Constants.spriteScale + Constants.explosionScale),
          ),
          anchor: Anchor.center,
        );

  final Timer _timer = Timer(Constants.explosionLifetime);

  @override
  Future<void> onMount() async {
    _timer
      ..onTick = removeFromParent
      ..start();
    return super.onMount();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
  }

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.spriteList(
      Assets.explosions
          .map((path) => Sprite(Flame.images.fromCache(path)))
          .toList(),
      stepTime: Constants.explosionFrameDuration,
      loop: true,
    );
  }
}
