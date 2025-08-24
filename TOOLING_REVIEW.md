# Tooling Review

| Tool / command | Mentioned in docs | Observed behaviour |
| --- | --- | --- |
| `./scripts/flutterw --version` | README.md – example wrapper usage | ✅ Reports Flutter 3.32.8 |
| `./scripts/dartw pub get` | README.md – example wrapper usage | ✅ Resolves dependencies successfully |
| `./scripts/dartw format` | Copilot instructions require running format | ⚠️ Runs but flags two unformatted files |
| `./scripts/dartw analyze` | Copilot instructions require static analysis | ✅ No issues found |
| `./scripts/flutterw test` | Copilot instructions require tests | ❌ Fails: no `*_test.dart` files in `test/` |
| `./scripts/flutterw run -d chrome` | Manual testing guide suggests Chrome target | ❌ No Chrome device found |
| `./scripts/flutterw run -d web-server` | Manual testing guide suggests web-server target | ⚠️ Launches but warns project isn’t configured for web |
| `./scripts/flutterw build web --release` | Web README describes release build | ❌ Fails: missing `index.html` |
| `fvm flutter doctor` / `fvm dart format` | Plan/TASKS show FVM usage | ❌ `fvm` command not found |
| `./scripts/markdownlint.sh '**/*.md'` | Plan recommends markdownlint after doc edits | ✅ Uses local install or `npx --yes` |

## Notes

- Install FVM or remove FVM-specific instructions if not required.
- Add web support (`flutter create .`) and `web/index.html` to enable builds/run targets.
- Provide Chrome or Edge in the environment if Chrome device debugging is desired.
- Use `scripts/markdownlint.sh` to lint docs without interactive prompts.
