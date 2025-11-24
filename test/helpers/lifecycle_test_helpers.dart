import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import 'package:space_game/assets.dart';
import 'package:space_game/game/space_game.dart';
import 'package:space_game/services/audio_service.dart';
import 'package:space_game/services/storage_service.dart';
import 'package:space_game/ui/game_over_overlay.dart';
import 'package:space_game/ui/hud_overlay.dart';
import 'package:space_game/ui/menu_overlay.dart';
import 'package:space_game/ui/pause_overlay.dart';

import '../test_images.dart';

final _lifecycleAssetPaths = [
  ...Assets.players,
  ...Assets.enemies,
  ...Assets.asteroids,
  ...Assets.explosions,
  Assets.bullet,
];

Future<void> loadLifecycleTestImages() async {
  await loadTestImages(_lifecycleAssetPaths);
}

Future<SpaceGame> createLifecycleTestGame({
  bool includeHudOverlay = false,
  bool includePauseOverlay = false,
  bool includeGameOverOverlay = false,
  double viewportSize = 100,
}) async {
  final storage = await StorageService.create();
  final audio = await AudioService.create(storage);
  audio.muted.value = true;
  final game = SpaceGame(storageService: storage, audioService: audio);
  game.overlays.addEntry(MenuOverlay.id, (_, __) => const SizedBox());
  if (includeHudOverlay) {
    game.overlays.addEntry(HudOverlay.id, (_, __) => const SizedBox());
  }
  if (includePauseOverlay) {
    game.overlays.addEntry(PauseOverlay.id, (_, __) => const SizedBox());
  }
  if (includeGameOverOverlay) {
    game.overlays.addEntry(GameOverOverlay.id, (_, __) => const SizedBox());
  }
  await game.onLoad();
  game.onGameResize(Vector2.all(viewportSize));
  return game;
}
