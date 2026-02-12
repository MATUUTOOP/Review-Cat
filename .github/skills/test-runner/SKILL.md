# Skill: test-runner

**Name:** test-runner

**Summary / Purpose:**
Runs tests by type using the repo's canonical test layout (`test/`).

**Owner:** @p3nGu1nZz

**Inputs:**
- `--unit|--integration|--bench|--all` and `--junit-output` / `--bench-output`

**Outputs:**
- test result exit code; optional JUnit XML; bench JSON

**Acceptance Criteria:**
- Returns non-zero on test failure; produces JUnit XML when requested.

**Testing Plan:**
- Integration: run against `test/fixtures/` example tests and verify outputs exist.
