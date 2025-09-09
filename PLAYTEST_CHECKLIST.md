# Manual Playtest Checklist

Based on MVP features in [PLAN.md](PLAN.md).

_Update this file whenever a player-facing feature is added or changed._

- [ ] Game loads on mobile and desktop browsers
- [ ] Touch and keyboard controls move the player
- [ ] Player can shoot and destroy a basic enemy
- [ ] Bullets travel in the direction the ship is facing
- [ ] Bullets spawn from the front of the player's ship
- [ ] When stationary, the ship rotates toward the nearest enemy within range
- [ ] Target button or `B` key toggles range rings display
- [ ] Minimap icon or `N` key toggles minimap with player heading arrow
- [ ] `F1` toggles debug overlays with hit boxes, starfield tile outlines and an
      FPS counter
- [ ] Asteroids spawn randomly and drift across the screen
- [ ] Enemies and asteroids show varied sprites
- [ ] Shooting an asteroid destroys it and increases the on-screen score
- [ ] Shooting an asteroid with the main cannon does not drop minerals
- [ ] Mining an asteroid increases the on-screen minerals
- [ ] Score resets when restarting the game
- [ ] Minerals reset when restarting the game
- [ ] HUD shows current score, minerals and health during play
- [ ] Collisions reduce player health; game over when health reaches zero
- [ ] Player ship flashes red when taking damage
- [ ] Shield Booster upgrade regenerates health over time when purchased
- [ ] Game states transition: menu → playing → upgrades → paused → game over
      → restart or menu
- [ ] Player can choose a ship from the menu before starting
- [ ] Selected ship persists between sessions
- [ ] Enter starts or restarts from the menu or game over; `R` restarts at any time
- [ ] Escape or `P` key pauses or resumes the game
- [ ] Deterministic world-space starfield renders consistently and prunes
      distant tiles to avoid memory leaks
- [ ] Sound effects play and can be muted from menu, HUD or game over overlay,
      or via the `M` key
- [ ] Laser shot sound plays when firing
- [ ] Explosion animation and sound play when a ship is destroyed
- [ ] Mining laser emits a looping sound while active
- [ ] Game can be paused and resumed
- [ ] Pausing mutes audio or lowers volume according to settings
- [ ] Pressing `H` shows a help overlay; `Esc` or `H` closes it and resumes play
- [ ] Pressing `U` shows an upgrades overlay and pauses the game; `Esc` or `U`
      closes it
- [ ] Settings button or `O` key opens settings overlay; sliders adjust volume,
      HUD button, minimap, text, joystick sizes, gameplay ranges and starfield
      tile size, density and brightness (default 0.75 for buttons and text) and
      reset button restores defaults
- [ ] Local high score persists between sessions
- [ ] PWA installability and offline play after initial load
- [ ] Performance acceptable on target devices
- [ ] Findings logged in `playtest_logs/` and next steps noted in [TASKS.md](TASKS.md)
