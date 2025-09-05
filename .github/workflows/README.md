# GitHub Actions Workflows

CI/CD automation for the project.

- `analyze.yml` – runs static analysis and tests on pull requests or can
  be triggered manually from the GitHub Actions tab.
- `deploy.yml` – builds the web release and publishes it. It runs on
  pushes to `main` and `develop` and can be triggered manually from the
  GitHub Actions tab.
- `deploy-preview.yml` – builds the current branch on pull requests or
  manual triggers and publishes it to a branch-specific preview path.

Workflows avoid interfering with each other by using concurrency groups.
The main deploy workflow also cancels any running preview deployments
before starting.

Workflows follow the lightweight pipeline described in [../../PLAN.md](../../PLAN.md).

### GitHub Pages Deployment

`deploy.yml` runs on pushes to `main` and `develop`, or can be triggered
manually via the GitHub Actions tab. It builds the web release and
deploys `build/web` to GitHub Pages:

- `main` → `gh-pages` (live site)
- `develop` → `gh-pages-staging` (preview)

`deploy-preview.yml` can be run manually to build the current branch and publish it under `previews/<branch>` on `gh-pages`.

GitHub Pages serves the contents of `gh-pages` at
`https://benhook1013.github.io/space-game/`. The `gh-pages-staging`
branch is deployed to
`https://benhook1013.github.io/space-game-staging/` for previews.
