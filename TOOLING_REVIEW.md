# Tooling Review

| Tool / command | Mentioned in docs | Observed behaviour |
| --- | --- | --- |
| `./scripts/flutterw --version` | README.md – example wrapper usage | ✅ Reports Flutter 3.32.8 |
| `./scripts/dartw pub get` | README.md – example wrapper usage | ✅ Resolves dependencies successfully |
| `./scripts/dartw format` | Copilot instructions require running format | ✅ Formats code with no pending changes |
| `./scripts/dartw analyze` | Copilot instructions require static analysis | ✅ No issues found |
| `./scripts/flutterw test` | Copilot instructions require tests | ✅ All tests passed |
| `./scripts/flutterw run -d chrome` | Manual testing guide suggests Chrome target | ⚠️ Requires headless wrapper; may hang without display |
| `./scripts/flutterw run -d web-server` | Manual testing guide suggests web-server target | ✅ Serves app locally |
| `./scripts/flutterw build web --release` | Web README describes release build | ✅ Builds to `build/web` |
| `fvm flutter doctor` / `fvm dart format` | Plan/TASKS show FVM usage | ✅ FVM available |
| `npm --version` | Setup script ensures Node.js | ✅ 11.4.2 without proxy warnings |
| `./scripts/markdownlint.sh '**/*.md'` | Plan recommends markdownlint after doc edits | ✅ Uses local install or `npx --yes` |

## Notes

- Headless Chrome wrapper is provided but may still fail on some CI runners; use `-d web-server` as a fallback.
