# test/unit/

Unit tests should be fast, deterministic, and suitable for PR gates.

Conventions:

- File naming: `*_test.<ext>` or `test_*.py` depending on language
- Prefer small, focused, isolated tests
- Emit JUnit XML when possible for CI integration

See `docs/specs/components/TestDirectory.md` for cross-repo policies.