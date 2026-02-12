# Repository Scaffold (Phase 0)

## Overview

This spec documents the minimal repository layout and the contract for the
build/test gate used by the Director and dev harness.

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

**Phase:** Phase 0 — Bootstrap & Dev Harness  
**Component:** Repository Structure / Build Gate  
**Priority:** Critical