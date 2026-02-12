# test/

This directory holds repository-level tests and test resources.

Structure:

- `unit/` — unit tests
- `integration/` — integration tests
- `bench/` — benchmarks
- `e2e/` — end-to-end tests (optional)
- `fuzz/` — fuzz tests (optional)
- `fixtures/` — shared fixtures and replay data

Note: per repo convention, executable test runners live under `scripts/` (for example `scripts/test.sh`).

See `docs/specs/dev/components/TestDirectory.md` for full conventions and CI expectations.