# Test Directory Specification

## Overview

This document defines the canonical, language-agnostic layout and conventions
for repository tests so that CI, Director validation, and agents can discover
and run tests deterministically.

## Requirements

1. The canonical test root MUST be `test/`.
2. The canonical subdirectories SHOULD exist as described below and include `README.md` stubs.
3. The repo MUST provide a wrapper at `scripts/test.sh` supporting the flags described in this spec.

## Interfaces

## Layout

The canonical test tree lives at the repo root `test/` with the following
sub-directories:

- `test/unit/` — fast, isolated unit tests (PR gate)
- `test/integration/` — integration tests (may require containers or ephemeral infra)
- `test/bench/` — benchmarks (JSON/CSV output, preserved as artifacts)
- `test/e2e/` — end-to-end tests (optional; long-running)
- `test/fuzz/` — fuzz / property-based tests (optional)
- `test/fixtures/` — shared test data and fixtures

Each directory SHOULD include a `README.md` explaining conventions and
example file names for that test type.

## Naming and Discovery

- Prefer explicit conventions per language (e.g., `*_test.cpp`, `test_*.py`).
- Tests MUST be discoverable by conventional runners (Catch2, pytest, etc.).
- Tests should include metadata tags where supported (e.g., `[integration]`, `[bench]`).

## Runner contract (spec)

Rather than hard-coding a runner, the repo SHOULD define a small wrapper
specification for `scripts/test.sh` (planned), which supports the following
flags:

- `--unit` — run unit tests only
- `--integration` — run integration tests only
- `--bench` — run benchmark suite and emit JSON artifacts
- `--all` — run all tests (with safe timeouts)

The wrapper SHOULD accept `--junit-output <path>` for JUnit XML test reporting
and `--bench-output <path>` for benchmark JSON artifacts. Exit codes must
follow normal test semantics (0 for success, non-zero for failure).

## Reporting formats

- Unit & integration tests: JUnit XML is the preferred CI-friendly format.
- Benchmarks: stable JSON or CSV containing name, value(s), units, and metadata.

## CI strategy

- `unit` tests: run on PRs as a fast gate
- `integration` tests: run on merge or on-demand PR job (longer-running)
- `bench` jobs: scheduled (nightly) to detect regressions and publish artifacts

## Test isolation expectations

- Default: no network access unless explicitly allowed
- File access limited to `test/fixtures/` and temporary directories
- Each test run should be reproducible via recorded fixtures and replays

## Acceptance criteria

- [ ] `test/` exists with the canonical subdir layout and `README.md` files
- [ ] `docs/specs/dev/TESTING_STRATEGY.md` references this spec and the runner contract
- [ ] `scripts/test.sh` exists and implements the runner contract
- [ ] CI job contracts defined (PR/unit gate; integration on-demand/merge; scheduled benchmarks)

## Test cases

- Running `scripts/test.sh --unit` executes only unit tests.
- Running `scripts/test.sh --all` runs all suites with safe timeouts.
- `--junit-output <path>` produces a valid JUnit XML file.

## Edge cases

- No tests exist yet (runner should succeed or emit a clear “no tests” message per policy).
- Benchmarks produce malformed JSON (runner must fail with actionable errors).

## Non-functional constraints

- Isolation: tests should default to no network and use temporary directories.
- Reproducibility: fixtures and replay tests should be preferred when possible.

## Related

- Issue #30 — Tests: Create `/test` directory (unit/integration/bench/etc)
- `docs/specs/dev/TESTING_STRATEGY.md`

**Phase:** Phase 0/1 — Testing & QA  
**Component:** Testing / CI  
**Priority:** High