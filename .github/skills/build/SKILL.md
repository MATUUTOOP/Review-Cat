# Skill: build

**Name:** build

**Summary / Purpose:**
Builds the repository (default via CMake) and produces an artifact for testing.

**Owner:** @p3nGu1nZz

**Inputs:**
- optional `--config` (Debug|Release)

**Outputs:**
- build artifacts under `build/` or `out/`

**Acceptance Criteria:**
- Exit 0 on successful build, non-zero otherwise.

**Testing Plan:**
- Integration test: run build in a clean environment and verify artifact exists.

**Related:** `docs/specs/components/RepoScaffold.md`