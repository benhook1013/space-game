# Manual Playtest Checklist

Based on MVP features in [PLAN.md](PLAN.md).

_Update this file whenever a player-facing feature is added or changed._

- [ ] Game loads on mobile and desktop browsers
- [ ] Touch and keyboard controls move the player
- [ ] Player can shoot and destroy a basic enemy
- [ ] Bullets travel in the direction the ship is facing
- [ ] When stationary, the ship rotates toward the nearest enemy within range
- [ ] Asteroids spawn randomly and drift across the screen
- [ ] Enemies and asteroids show varied sprites
- [ ] Shooting an asteroid destroys it and increases the on-screen score
- [ ] Score resets when restarting the game
- [ ] HUD shows current and high scores during play
- [ ] Collisions reduce player health; game over when health reaches zero
- [ ] Game states transition: menu → playing → paused → game over → restart or menu
- [ ] Player can choose a ship from the menu before starting
- [ ] Enter starts or restarts from the menu or game over; `R` restarts at any time
- [ ] Escape or `P` key pauses or resumes the game; `Q` returns to the menu from
      pause or game over, `Esc` also returns to the menu from game over
- [ ] Parallax starfield renders behind gameplay
- [ ] Sound effects play and can be muted from menu, HUD, pause or game over overlay,
      or via the `M` key
- [ ] Game can be paused, resumed and return to menu (including from game over)
- [ ] Pressing `H` shows a help overlay; `Esc` or `H` closes it and resumes play
- [ ] Local high score persists between sessions
- [ ] PWA installability and offline play after initial load
- [ ] Performance acceptable on target devices
- [ ] Findings logged in `playtest_logs/` and next steps noted in [TASKS.md](TASKS.md)
