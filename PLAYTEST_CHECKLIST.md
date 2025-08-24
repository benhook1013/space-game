# Manual Playtest Checklist

Based on MVP features in [PLAN.md](PLAN.md).

_Update this file whenever a player-facing feature is added or changed._

- [ ] Game loads on mobile and desktop browsers
- [ ] Touch and keyboard controls move the player
- [ ] Player can shoot and destroy a basic enemy
- [ ] Asteroids spawn randomly and drift across the screen
- [ ] Shooting an asteroid destroys it and increases the on-screen score
- [ ] Score resets when restarting the game
- [ ] Collisions reduce player health; game over when health reaches zero
- [ ] Game states transition: menu → playing → paused → game over → restart or menu
- [ ] Parallax starfield renders behind gameplay
- [ ] Sound effects play and can be muted
- [ ] Game can be paused, resumed and return to menu (including from game over)
- [ ] Local high score persists between sessions
- [ ] PWA installability and offline play after initial load
- [ ] Performance acceptable on target devices
- [ ] Findings logged in `playtest_logs/` and next steps noted in [TASKS.md](TASKS.md)
