# GitHub Actions Workflows

CI/CD automation for the project.

- `ci.yml` – formats code, runs static analysis and tests.
- `deploy.yml` – builds the web release and publishes it.

Workflows follow the lightweight pipeline described in [../../PLAN.md](../../PLAN.md).

### GitHub Pages Deployment

`deploy.yml` runs on pushes to `main` and `develop`. It builds the web
release and deploys `build/web` to GitHub Pages:

- `main` → `gh-pages` (live site)
- `develop` → `gh-pages-staging` (preview)

GitHub Pages serves the contents of `gh-pages` at
`https://<your-GitHub-username>.github.io/space-game/`.
