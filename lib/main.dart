import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'assets.dart';
import 'game/space_game.dart';
import 'theme/game_theme.dart';
import 'ui/game_over_overlay.dart';
import 'ui/hud_overlay.dart';
import 'ui/menu_overlay.dart';
import 'ui/pause_overlay.dart';
import 'ui/help_overlay.dart';
import 'ui/upgrades_overlay.dart';
import 'ui/settings_overlay.dart';
import 'ui/game_text.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Assets.loadEssential();
  final storage = await StorageService.create();
  final audio = await AudioService.create(storage);
  final settings = SettingsService();
  final focusNode = FocusNode();

  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  );
  const gameColors = GameColors.dark;

  final game = SpaceGame(
    storageService: storage,
    audioService: audio,
    settingsService: settings,
    focusNode: focusNode,
    colorScheme: colorScheme,
    gameColors: gameColors,
  );

  // Begin loading non-essential assets immediately. Progress is reported to
  // the main menu overlay, which shows a loading bar until all assets are
  // ready. The game itself will await completion before starting.
  game.startLoadingAssets();

  runApp(
    GameTextScale(
      textScale: settings.textScale,
      child: GameApp(
        game: game,
        focusNode: focusNode,
        colorScheme: colorScheme,
        gameColors: gameColors,
      ),
    ),
  );
}

class GameApp extends StatefulWidget {
  const GameApp({
    required this.game,
    required this.focusNode,
    required this.colorScheme,
    required this.gameColors,
    super.key,
  });

  final SpaceGame game;
  final FocusNode focusNode;
  final ColorScheme colorScheme;
  final GameColors gameColors;

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (widget.game.isLoaded && widget.game.stateMachine.isPlaying) {
          widget.game.resumeEngine();
          widget.game.focusGame();
        }
        break;
      default:
        widget.game.pauseEngine();
        final laser = widget.game.miningLaser;
        if (laser != null && laser.isMounted) {
          laser.stopSound();
        }
        widget.game.audioService.stopAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: widget.colorScheme,
        useMaterial3: true,
        extensions: [widget.gameColors],
      ),
      home: GameWidget<SpaceGame>(
        game: widget.game,
        focusNode: widget.focusNode,
        // Automatically request keyboard focus so web players can use WASD
        // without tapping the canvas first.
        autofocus: true,
        overlayBuilderMap: {
          MenuOverlay.id: (context, SpaceGame game) => MenuOverlay(game: game),
          HudOverlay.id: (context, SpaceGame game) => HudOverlay(game: game),
          PauseOverlay.id: (context, SpaceGame game) => const PauseOverlay(),
          GameOverOverlay.id: (context, SpaceGame game) =>
              GameOverOverlay(game: game),
          HelpOverlay.id: (context, SpaceGame game) => HelpOverlay(game: game),
          UpgradesOverlay.id: (context, SpaceGame game) =>
              UpgradesOverlay(game: game),
          SettingsOverlay.id: (context, SpaceGame game) =>
              SettingsOverlay(game: game),
        },
      ),
    );
  }
}
