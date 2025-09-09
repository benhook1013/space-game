import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'assets.dart';
import 'game/space_game.dart';
import 'game/game_state.dart';
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

  final lifecycleObserver = _AppLifecycleObserver(game);

  runApp(
    GameTextScale(
      textScale: settings.textScale,
      child: GameApp(
        game: game,
        focusNode: focusNode,
        lifecycleObserver: lifecycleObserver,
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
    required this.lifecycleObserver,
    required this.colorScheme,
    required this.gameColors,
    super.key,
  });

  final SpaceGame game;
  final FocusNode focusNode;
  final _AppLifecycleObserver lifecycleObserver;
  final ColorScheme colorScheme;
  final GameColors gameColors;

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(widget.lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(widget.lifecycleObserver);
    super.dispose();
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

class _AppLifecycleObserver extends WidgetsBindingObserver {
  _AppLifecycleObserver(this.game);

  final SpaceGame game;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (game.isLoaded && game.stateMachine.state == GameState.playing) {
          game.resumeEngine();
          game.focusGame();
        }
        break;
      default:
        game.pauseEngine();
        final laser = game.miningLaser;
        if (laser != null && laser.isMounted) {
          laser.stopSound();
        }
        game.audioService.stopAll();
    }
  }
}
