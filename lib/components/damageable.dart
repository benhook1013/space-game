import 'package:flame/components.dart';

/// Mixin for components that can receive damage.
///
/// Classes mixing this in should handle any side effects such as playing
/// hit animations or removing themselves when health reaches zero.
mixin Damageable on Component {
  /// Applies [amount] of damage to the component.
  void takeDamage(int amount);
}
