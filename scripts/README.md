# Development scripts

Use Flutter/Dart wrappers from the repository root. The wrappers can bootstrap
and configure the pinned SDK; read [environment notes](../docs/development/ENVIRONMENT.md)
before using them in an offline workspace. Keep SDKs and caches out of Git.

## Verified edit-round application

`scripts/apply_edit_round.py` uses only Python 3.9+ and the Git command-line tool.
A byte-identical copy is included at the top level of each handoff ZIP so it can
verify the first round before that script exists in the target repository.

```bash
python3 scripts/apply_edit_round.py --bundle ../space-game-round-002-pwa-safety --repo .
# Only after reading the handoff and a successful check:
python3 scripts/apply_edit_round.py --bundle ../space-game-round-002-pwa-safety --repo . --apply
```

Default mode leaves tracked files, the real index and branch references
unchanged. Git may create otherwise harmless objects during temporary-index
verification. `--apply` stages changes but does not commit/push. Keep handoffs
outside the repo. Run no other author, formatter or Git operation concurrently.

The helper deliberately rejects unrelated baseline changes instead of silently
rebasing. It verifies `changes.patch` with `BASE.json` and checks the expected
result tree before applying. SHA-256 metadata is an integrity check, not an
independent signature. Do not treat an untrusted handoff as safe to execute.

Run helper tests without downloading dependencies or installing Flutter:

```bash
python3 -m unittest discover -s scripts/tests -p 'test_*.py' -v
```

See [WORKFLOW.md](../WORKFLOW.md) for packaging and the validation contract and
[WSL.md](../docs/development/WSL.md) for first-clone/integration instructions.
