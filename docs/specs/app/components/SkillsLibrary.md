# Skills Library (`.github/skills/`)

## Overview

A **skills library** provides a canonical, discoverable place for small,
reusable automation "skills" that agents or humans can invoke. Each skill is
documented by a `SKILL.md` file and placed under `.github/skills/<skill-name>/`.

## Requirements

1. A template MUST exist at `.github/skills/_TEMPLATE_/SKILL.md`.
2. Each skill MUST live at `.github/skills/<skill-name>/SKILL.md`.
3. A CI check MUST validate that each `SKILL.md` contains the required sections.

## Interfaces

### `SKILL.md` format

## SKILL.md format

Each `SKILL.md` SHOULD include the following sections:

- **Name** (snake-case)
- **Summary / Purpose**
- **Owner** (GitHub user or team)
- **Inputs** (DTOs, CLI args, or message schema)
- **Outputs** (artifacts, files, DTOs, side-effects)
- **Examples** (invocation and sample outputs)
- **Acceptance Criteria** (pass/fail rules)
- **Testing Plan** (unit/integration tests to exercise the skill)
- **Implementation Guidance** (tools, commands, permissions)
- **Related Specs / Docs**

Store a template at `.github/skills/_TEMPLATE_/SKILL.md` and individual skills
at `.github/skills/<skill-name>/SKILL.md`.

## Initial suggested catalog

- `build` — build the repo (CMake-based by default)
- `test-runner` — run tests by type (unit/integration/bench)
- `bench-runner` — run and collect benchmark results
- `linter` — run static analysis
- `worktree-manager` — create/manage git worktrees
- `pr-manager` — create/update PRs, amend PR bodies
- `memory-query` — search engrams and `MEMORY.md`
- `docgen` — generate docs snippets / update TOCs

## CI / Validation

Add a lightweight `skill-lint` GitHub Action that verifies presence and
required fields in `SKILL.md` files on PRs.

## Acceptance criteria

- [ ] `.github/skills/_TEMPLATE_/SKILL.md` exists
- [ ] Initial skeletons for prioritized skills exist
- [ ] `skill-lint` workflow validates SKILL.md presence & required sections

## Test cases

- Add a dummy skill folder missing required sections and verify CI fails.
- Add a well-formed skill and verify CI passes.

## Edge cases

- Skill folder names with uppercase or spaces (should be rejected by lint).
- Duplicate skill names (lint should fail deterministically).

## Non-functional constraints

- CI should be fast (lint only; no heavy builds).
- Lint rules should be deterministic to avoid flaky PR checks.

**Phase:** Phase 0/1 — Skills Library / Agent UX  
**Component:** Agent Skills / Architecture  
**Priority:** High