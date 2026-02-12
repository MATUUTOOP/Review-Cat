# test/integration/

Integration tests exercise boundaries: git operations, filesystem, and
lightweight container interactions. Prefer hermetic setup and teardown.

Conventions:

- Mark tests with `[integration]` where supported
- Use `test/fixtures/` for seed data and replays
- Integration jobs may run less frequently in CI than unit tests

See `docs/specs/components/TestDirectory.md`.