# GitHub Actions Workflows

CI/CD automation for the project.

- `ci.yml` – formats code, runs static analysis and tests.
- `deploy.yml` – builds the web release and publishes it.
- `deploy-preview.yml` – manually builds the current branch and publishes it to a branch-specific preview path.

All workflows use concurrency groups to cancel in-progress runs when new
commits arrive.

Workflows follow the lightweight pipeline described in [../../PLAN.md](../../PLAN.md).

### GitHub Pages Deployment

`deploy.yml` runs on pushes to `main` and `develop`. It builds the web
release and deploys `build/web` to GitHub Pages:

- `main` → `gh-pages` (live site)
- `develop` → `gh-pages-staging` (preview)

`deploy-preview.yml` can be run manually to build the current branch and publish it under `previews/<branch>` on `gh-pages`.

GitHub Pages serves the contents of `gh-pages` at
`https://benhook1013.github.io/space-game/`. The `gh-pages-staging`
branch is deployed to
`https://benhook1013.github.io/space-game-staging/` for previews.
