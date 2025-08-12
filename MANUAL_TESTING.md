# Manual Testing Strategy

Manual testing fills the gap until automated tests are added.

- Work primarily on the `main` branch; create short-lived feature branches only
  when needed.
- Run the web build locally with `fvm flutter run -d chrome` or `-d web-server`
  to verify changes.
- Use the [PLAYTEST_CHECKLIST.md](PLAYTEST_CHECKLIST.md) during each round of
  testing and log findings in `playtest_logs/`.
