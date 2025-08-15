# Copilot PR Review Guide

This file outlines expectations for automated pull request reviews.

## Repository Rules
- **Read and follow [`AGENTS.md`](AGENTS.md)** for development guidelines, coding style, and project conventions.
- Ensure assets and documentation respect the project structure described in `AGENTS.md`.

## Required Checks
- Format code with `./scripts/dartw format`.
- Run static analysis with `./scripts/dartw analyze`.
- Execute tests with `./scripts/flutterw test`.

## Documentation & Testing
- For manual test scenarios, see [`MANUAL_TESTING.md`](MANUAL_TESTING.md) and [`PLAYTEST_CHECKLIST.md`](PLAYTEST_CHECKLIST.md).
- Consult [`PLAN.md`](PLAN.md), [`DESIGN.md`](DESIGN.md), and [`TASKS.md`](TASKS.md) when verifying that changes align with project goals.

Reviewers should confirm that contributors have followed these instructions and referenced the above resources as needed.
