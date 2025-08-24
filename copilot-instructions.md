# Copilot PR Review Guide

This file outlines expectations for automated pull request reviews.

## Repository Rules

- **Read and follow [`AGENTS.md`](AGENTS.md)** for development guidelines, coding style, and project conventions.
- Ensure assets and documentation respect the project structure described in `AGENTS.md`.

## Required Checks

- Format code with `./scripts/dartw format` (or `scripts\\dartw.ps1 format` on
  Windows).
- Run static analysis with `./scripts/dartw analyze` (or
  `scripts\\dartw.ps1 analyze` on Windows).
- Execute tests with `./scripts/flutterw test` (or
  `scripts\\flutterw.ps1 test` on Windows).

## Documentation & Testing

- For manual test scenarios, see [`MANUAL_TESTING.md`](MANUAL_TESTING.md) and [`PLAYTEST_CHECKLIST.md`](PLAYTEST_CHECKLIST.md).
- Consult [`PLAN.md`](PLAN.md), [`DESIGN.md`](DESIGN.md), and [`TASKS.md`](TASKS.md) when verifying that changes align with project goals.

Reviewers should confirm that contributors have followed these instructions and referenced the above resources as needed.
