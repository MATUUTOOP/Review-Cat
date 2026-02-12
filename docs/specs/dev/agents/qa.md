# QA Agent

## Overview

The **qa** agent adds and maintains tests and replay fixtures for reliable validation.

## Requirements

1. MUST add tests for behavioral changes.
2. MUST prefer reproducible fixtures/replays over brittle live dependencies.
3. MUST classify flaky tests and propose follow-ups.

## Interfaces

- **Inputs:** PR diffs, specs acceptance criteria, and existing test suite.
- **Outputs:** new/updated tests, fixtures, and a validation report.

## Acceptance criteria

- New tests fail before the fix and pass after.
- Test changes are deterministic.

## Test cases

- Add a unit test for a bug fix.
- Record a replay fixture for an integration path (when applicable).

## Edge cases

- Flaky upstream dependency: isolate behind replay/fixture.

## Non-functional constraints

- Speed: keep PR-gating tests fast.
- Reproducibility: no hidden network dependencies by default.