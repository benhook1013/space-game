# GitHub Workflows

Continuous integration and deployment.

- `ci.yml` runs `dart format .` and `flutter analyze` on pull requests.
- `deploy.yml` builds the web target and publishes to GitHub Pages.
- Commands should use the pinned SDK via FVM; update workflows if needed to stay aligned with [PLAN.md](../../PLAN.md).
