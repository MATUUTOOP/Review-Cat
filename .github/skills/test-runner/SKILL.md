---
name: test-runner
description: Runs tests by suite using the repo's canonical test layout (test/). Use when asked to run unit/integration/bench tests, troubleshoot failures, or validate the green gate.
compatibility: Requires bash; unit tests require cmake/ctest if using the CMake test registry.
metadata:
  category: build-and-ci
  owner: p3nGu1nZz
  version: "0.1"
  tags: "tests unit integration bench junit"
---

# Skill: test-runner

## What this skill does

Runs tests via `./scripts/test.sh`.

## How to use

- Unit tests: `./scripts/test.sh --unit`
- Integration tests: `./scripts/test.sh --integration`
- Benchmarks: `./scripts/test.sh --bench --bench-output build/bench.json`
- All: `./scripts/test.sh --all`

## Outputs

- Exit code: 0 on success, non-zero on failure
- Optional JUnit XML: `--junit-output <path>`
- Optional bench JSON: `--bench-output <path>`

## Related

- `docs/specs/dev/components/TestDirectory.md`
- `docs/specs/dev/TESTING_STRATEGY.md`
