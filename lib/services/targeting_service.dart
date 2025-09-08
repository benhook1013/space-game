import 'package:flame/components.dart';

import '../components/player.dart';
import '../game/event_bus.dart';
import '../util/component_tracker.dart';

/// Tracks key targets like the player for AI systems to query.
class TargetingService {
  TargetingService(GameEventBus events)
      : _playerTracker = ComponentTracker<PlayerComponent>(events);

  final ComponentTracker<PlayerComponent> _playerTracker;

  /// Current position of the tracked player, if any.
  Vector2? get playerPosition => _playerTracker.component?.position;

  /// Cancels event subscriptions and releases resources.
  void dispose() => _playerTracker.dispose();
}
