# ✅ Task List

Tracking immediate work to reach the MVP. See [PLAN.md](PLAN.md) and [DESIGN.md](DESIGN.md)
for context, and milestone docs (`milestone-*.md`) for detailed goals.

## Setup ([milestone-setup.md](milestone-setup.md))

- [x] Install FVM and fetch the pinned Flutter SDK (version `3.32.8`).
- [x] Run `fvm flutter doctor` to verify the environment.
- [x] Scaffold the Flutter project (`fvm flutter create .`) if not already.
- [x] Enable web support (`fvm flutter config --enable-web`).
- [x] Add Flame, `flame_audio` and `shared_preferences` to `pubspec.yaml`.
- [x] Run `fvm flutter pub get` to install dependencies.
- [x] Create placeholder `assets.dart` and `constants.dart` to centralise asset
  paths and tunable values.
- [x] Add a tiny `log.dart` helper that wraps `debugPrint`.
- [x] Commit generated folders (`lib/`, `web/`, etc.).
- [x] Set up GitHub Actions workflow for lint, test and web deploy.
- [x] Document placeholder assets and credits.
- [x] Create `assets_manifest.json` to list bundled assets for caching
  (see `assets_manifest.md`).

## Core Loop ([milestone-core-loop.md](milestone-core-loop.md))

- [x] Player ship moves with joystick or keyboard.
- [x] Ship can shoot and destroy a basic enemy type.
- [x] Random asteroids spawn and can be mined for score.
- [x] Destroying enemies awards score.
- [x] Game states: menu → playing → game over with restart.

## Polish ([milestone-polish.md](milestone-polish.md))

- [x] Parallax starfield renders behind gameplay.
- [x] Implement `audio_service.dart` wrapping `flame_audio` with a
      mute toggle.
- [x] Implement `storage_service.dart` using `shared_preferences`
      to persist the local high score.
- [x] Simple HUD and menus layered with Flutter overlays.

## PWA

- [x] Add `web/manifest.json` and placeholder icons for installable PWA.
- [x] Review service worker caching strategy and add custom `sw.js` for
      cache-first asset handling.

## Testing

- [x] Add unit tests for storage and audio services.
- [x] Add unit tests verifying bullet, asteroid and enemy pooling reuse.
- [x] Add unit test ensuring help overlay toggles pause state.

## Optimisation

- [x] Add bullet, asteroid and enemy object pools to reduce allocations.

## Enhancements

- [x] Pause overlay with resume and menu options, toggled via HUD and Escape or
      `P` key.
- [x] Game over overlay offers menu option to return to the title screen.
- [x] Player health tracked and shown in HUD; game over when depleted.
- [x] Mute toggle available on menu, HUD, pause and game over overlays.
- [x] Keyboard shortcut `M` toggles mute.
- [x] Keyboard shortcut `P` pauses or resumes the game.
- [x] Keyboard shortcuts: `Enter` starts or restarts from the menu or game over;
      `R` restarts during play, pause or game over.
- [x] Keyboard shortcut `Q` returns to the menu from pause or game over.
- [x] Help overlay lists controls and can be toggled with a button or the `H` key;
      `Esc` also closes it.
- [x] HUD displays current score, minerals and health.
- [x] Limit player fire rate with a brief cooldown.
- [x] Keyboard shortcut `F1` toggles debug overlays.
- [x] Audio volume lowers when the game is paused.
- [x] Menu includes button to reset the high score.
- [x] Menu allows choosing between multiple ship sprites and persists the selection.
- [x] Upgrades overlay accessible via HUD button or the `U` key where purchases
      persist across sessions.
- [x] HUD button or `B` key toggles range rings for targeting, Tractor Aura and mining.
- [x] Settings overlay with sliders for HUD, text, joystick, targeting,
      Tractor Aura and mining ranges, plus reset button.

- [x] Persist purchased upgrades across sessions using `StorageService`.

## Next Steps

- [x] Spawn enemy groups on a timer.
- [x] Add a mining laser that automatically targets and fires at nearby
      asteroids.
- [x] Drop mineral pickups from asteroids and track the player's total.
- [x] Pull nearby pickups toward the player with a Tractor Aura.
- [x] Auto-aim the primary weapon at the closest enemy when stationary.
- [x] Refine auto-aim targeting behaviour for smoother updates.
- [x] Design a broad upgrade system where minerals purchase new weapon and ship
      upgrades.
- [x] Implement upgrade effects and apply them to gameplay systems.
- [x] Expand the game world beyond the current single-screen map.
- [x] Attach a `CameraComponent` that follows the player with no fixed bounds.
- [x] Spawn asteroids and enemies just ahead of the player and despawn those
      far behind.
- [x] Tile the parallax starfield so it scrolls seamlessly.
- [x] Add a minimap or other navigation aid for exploring the larger world.
- [ ] Update the background system to replace the player-following parallax starfield with a deterministic world-space starfield. Generate stars per chunk using Poisson-disk sampling seeded by chunk coordinates. Modulate density with Simplex noise for subtle clusters. Render stars as pinpoint circles of varying size/brightness with CustomPainter, cached per chunk. The player moves over this static starfield, ensuring consistent, realistic spacing and density patterns.
