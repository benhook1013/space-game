import 'dart:async';
import 'package:flame/components.dart';

import '../components/player.dart';
import '../game/event_bus.dart';

/// Tracks key targets like the player for AI systems to query.
class TargetingService {
  TargetingService(GameEventBus events) {
    _spawnSub =
        events.on<ComponentSpawnEvent<PlayerComponent>>().listen((event) {
      _player = event.component;
    });
    _removeSub =
        events.on<ComponentRemoveEvent<PlayerComponent>>().listen((event) {
      if (_player == event.component) {
        _player = null;
      }
    });
  }

  late final StreamSubscription<ComponentSpawnEvent<PlayerComponent>> _spawnSub;
  late final StreamSubscription<ComponentRemoveEvent<PlayerComponent>>
      _removeSub;

  PlayerComponent? _player;

  /// Current position of the tracked player, if any.
  Vector2? get playerPosition => _player?.position;

  /// Cancels event subscriptions and releases resources.
  void dispose() {
    _spawnSub.cancel();
    _removeSub.cancel();
  }
}
