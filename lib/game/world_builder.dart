import '../components/player.dart';
import '../components/mining_laser.dart';
import '../components/enemy_spawner.dart';
import '../components/asteroid_spawner.dart';
import 'space_game.dart';

/// Builds the initial game world and attaches core components.
Future<void> buildWorld(SpaceGame game) async {
  game.player = PlayerComponent(
    joystick: game.controlManager.joystick,
    keyDispatcher: game.keyDispatcher,
    spritePath: game.selectedPlayerSprite,
  );
  await game.add(game.player);
  game.camera.follow(game.player, snap: true);
  final laser = MiningLaserComponent(player: game.player);
  game.miningLaser = laser;
  await game.add(laser);

  await game.controlManager.attachPlayer(game.player);

  game.enemySpawner = EnemySpawner();
  game.asteroidSpawner = AsteroidSpawner();
  await game.add(game.enemySpawner);
  await game.add(game.asteroidSpawner);
}
