# Repository Scaffold (Phase 0)

## Overview

This spec documents the minimal repository layout and the contract for the
build/test gate used by the Director and dev harness.

## Requirements

1. The repository MUST contain the top-level directories listed below (placeholders are acceptable initially).
2. The repo MUST define a stable validation gate contract for agents: `./scripts/build.sh && ./scripts/test.sh`.
3. `scripts/build.sh` and `scripts/test.sh` SHOULD be idempotent and safe to run repeatedly.

## Interfaces

### Directory layout

## Minimal directories to create (placeholders allowed)

- `app/` — runtime product (C++ sources, headers, config)
- `dev/` — dev harness (scripts, agents, plans)
- `scripts/` — convenience scripts (`build.sh`, `test.sh`, `clean.sh`)
- `.github/agents/` — repo-level Copilot agent profiles

Each directory MAY be introduced initially as a README placeholder explaining
what must live there.

## Build/test gate contract (planned)

- `scripts/build.sh` should perform an idempotent build (CMake-based)
- `scripts/test.sh` should accept `--unit/--integration/--bench/--all` flags
- The Director's validation gate will run: `./scripts/build.sh && ./scripts/test.sh`

## Acceptance criteria (docs-level)

- [ ] Placeholder directories and README stubs are created
- [ ] A spec exists documenting the build/test gate contract
- [ ] Follow-up issues exist for implementing scripts and minimal CMake

## Test cases

- `scripts/build.sh` succeeds on a clean checkout and on a second run without requiring manual cleanup.
- `scripts/test.sh --unit` runs successfully when only unit test placeholders exist.

## Edge cases

- Scripts are present but not executable (must fail with a clear message).
- A directory exists but contains only a placeholder README (allowed in Phase 0).

## Non-functional constraints

- Determinism: scripts should not depend on ambient machine state beyond declared toolchain prerequisites.
- UX: failures should be actionable (clear error output and exit codes).

**Phase:** Phase 0 — Bootstrap & Dev Harness  
**Component:** Repository Structure / Build Gate  
**Priority:** Critical