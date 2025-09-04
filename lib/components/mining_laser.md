# MiningLaserComponent

Automatically targets the nearest asteroid within range and mines it with
discrete pulses.

- Searches for the closest `AsteroidComponent` within the
  `SettingsService.miningRange` (defaults to `Constants.playerMiningRange`).
- Fires a pulse every `Constants.miningPulseInterval` seconds that deals
  `Constants.miningPulseDamage` damage.
- Renders a line between the player and target that widens as the pulse
  charges.
- Destroying an asteroid with the laser drops a `MineralComponent` the player
  can collect.
