import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/asset_lifecycle_service.dart';
import '../services/targeting_service.dart';
import '../services/upgrade_service.dart';
import 'control_manager.dart';
import 'health_regen_system.dart';
import 'starfield_manager.dart';
import 'space_game.dart';

/// Sets up game-wide services and managers.
void initGameServices(SpaceGame game) {
  final storedIndex = game.storageService.getPlayerSpriteIndex();
  if (storedIndex != game.selectedPlayerIndex.value) {
    unawaited(
      game.storageService.setPlayerSpriteIndex(game.selectedPlayerIndex.value),
    );
  }
  game.settingsService.attachStorage(game.storageService);
  game.debugMode = kDebugMode;
  // Respect the overridable pool factory to allow tests and subclasses
  // to inject custom pool implementations.
  // ignore: invalid_use_of_protected_member
  game.pools = game.createPoolManager();
  game.targetingService = TargetingService(game.eventBus);
  game.upgradeService = UpgradeService(
    scoreService: game.scoreService,
    storageService: game.storageService,
    settingsService: game.settingsService,
  );
  game.healthRegen = HealthRegenSystem(
    scoreService: game.scoreService,
    upgradeService: game.upgradeService,
  );
  game.starfieldManager = StarfieldManager(
    game: game,
    settings: game.settingsService,
    debugMode: game.debugMode,
  );
  game.controlManager = ControlManager(
    game: game,
    settings: game.settingsService,
    colorScheme: game.colorScheme,
  );
  game.assetLifecycle = AssetLifecycleService(
    game: game,
    audioService: game.audioService,
  );
}
