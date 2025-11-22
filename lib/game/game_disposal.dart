import 'dart:async';

import 'space_game.dart';

/// Cleans up services and managers owned by [SpaceGame].
void disposeGame(SpaceGame game) {
  game.ui.dispose();
  game.settingsService.dispose();
  game.scoreService.dispose();
  game.upgradeService.dispose();
  game.targetingService.dispose();
  game.stateMachine.dispose();
  game.controlManager.dispose();
  game.audioService.dispose();
  game.assetLifecycle.dispose();
  game.starfieldManager.dispose();
  game.pools.dispose();
  game.selectedPlayerIndex.dispose();
  if (game.ownsFocusNode) {
    game.focusNode.dispose();
  }
}

/// Disposes the [GameEventBus] after the game tree has been torn down.
Future<void> disposeEventBus(SpaceGame game) => game.eventBus.dispose();
