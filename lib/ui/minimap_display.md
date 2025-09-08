# minimap_display.dart

Renders a circular minimap widget that tracks nearby entities.

- Player is drawn as a small arrow pointing in the current heading.
- Enemies, asteroids and mineral pickups appear as coloured dots.
- The canvas updates each tick via a `Ticker` so the overlay stays live.
- `MiniMapDisplay` is typically embedded in the HUD and toggled with the `N`
  key or minimap icon.
