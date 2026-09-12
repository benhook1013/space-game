# Round 001: process and durable workspace knowledge

Date: 12 September 2026. Initially authored for manual handoff; subsequently
published to `main` through PR #716 at commit
`6b93b7d551bd11e995c71a1620b2b587a471cfe8`. That publication and its tree were
rechecked through GitHub during round `002-review-plan`.

## Baseline

Uploaded `space-game-main.zip`, upstream revision
`bb907372a5ba400398b7cae5db994d4593398e36`, reconstructed tree
`1f62779a366287bf7f13c7e120b2dd55a580f2c9`. The archive has no Git history.
Full input and result metadata were included in the original delivery's BASE.json.

## Outcome

Established [WORKFLOW.md](../../../WORKFLOW.md), accepted/deferred decisions,
dated environment observations and Ben's WSL guide. Linked them from the agent
guide, README, plan and design docs. Put current rounds ahead of the historical
MVP checklist. Added a dependency-free patch verifier/applier with regression
tests; it checks the complete baseline and result rather than only patch hunks.

Ben applied and pushed the feature branch. He then delegated routine publication
to the assistant. A direct non-forced update was rejected by the PR requirement;
the assistant created and merged PR #716 without weakening protection. It also
recorded permission to adopt Ben's newer SDK in a separate compatibility round.
Routine manual patch application is no longer Ben's expected workflow.

## Exclusions

No Dart/gameplay, sprites/audio, save format, dependency versions, lockfile,
Flutter bootstrap or deployment/service-worker behaviour changes. SDK preparation
occurred later and is recorded in the current environment notes, not as a result
of this original process round.

## Historical validation

Reported during original preparation: all 14 helper regression tests passed;
Python 3.9 syntax checks, 15 Bash documentation blocks, 12 relative links in six
new Markdown files and staged whitespace checks passed. Offline Markdown lint
could not start because markdownlint-cli was not cached (ENOTCACHED), so full
lint was NOT RUN. Independent patch roundtrip and source/mode checks were recorded
in the original validation handoff. The helper tests were reported passing again
before publication, with the remote tree matching the reviewed local tree.

These are historical results, not checks rerun during the later workspace outage.
Dart/Flutter analysis, tests, builds and game playtests were not established by
this process round. See [round 002](002-review-plan.md) and the active
[queue](../../../TASKS.md) rather than following the obsolete manual-integration
next steps from the initial handoff.
