# test/bench/

Benchmarks should produce machine-readable artifacts (JSON/CSV) suitable for
regression detection and storage as CI artifacts.

Conventions:

- Include metadata (commit, date, machine tags)
- Output stable JSON with fields: `name`, `value`, `unit`, `tags`
- Benchmarks may be scheduled nightly

See `docs/specs/dev/components/TestDirectory.md`.