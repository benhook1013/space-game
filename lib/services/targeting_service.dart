import 'package:flame/components.dart';

import '../components/player.dart';
import '../game/event_bus.dart';

/// Tracks key targets like the player for AI systems to query.
class TargetingService {
  TargetingService(GameEventBus events) {
    events.on<ComponentSpawnEvent<PlayerComponent>>().listen((event) {
      _player = event.component;
    });
    events.on<ComponentRemoveEvent<PlayerComponent>>().listen((event) {
      if (_player == event.component) {
        _player = null;
      }
    });
  }

  PlayerComponent? _player;

  /// Current position of the tracked player, if any.
  Vector2? get playerPosition => _player?.position;
}
