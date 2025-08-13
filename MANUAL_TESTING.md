# Manual Testing Strategy

Manual testing fills the gap until automated tests are added.
See [PLAN.md](PLAN.md) for the features currently in scope.

- Work primarily on the `main` branch; create short-lived feature branches only
  when needed.
- Run the web build locally with `fvm flutter run -d chrome` or `-d web-server`
  to verify changes.
- Use the [PLAYTEST_CHECKLIST.md](PLAYTEST_CHECKLIST.md) during each round of
  testing and log findings in `playtest_logs/`.
- Update [TASKS.md](TASKS.md) based on findings to stay aligned with the plan.
