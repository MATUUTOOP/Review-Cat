# Skills Library (`.github/skills/`)

## Overview

A **skills library** provides a canonical, discoverable place for small,
reusable automation **Agent Skills** that Copilot (and other skill-capable
clients) can load on-demand.

This repo stores project skills under:

- `.github/skills/<skill-name>/SKILL.md`

## Requirements

1. Each skill MUST live at `.github/skills/<skill-name>/SKILL.md`.
2. Each `SKILL.md` MUST start with YAML frontmatter containing:
	- `name` (required)
	- `description` (required)
3. The frontmatter `name` MUST match the parent directory name.
4. A template SHOULD exist at `.github/skills/skill-template/SKILL.md`.
5. A CI check MUST validate skill frontmatter and naming constraints.

## Interfaces

### `SKILL.md` file format

`SKILL.md` is a Markdown file with **YAML frontmatter** followed by an arbitrary
Markdown body.

Required frontmatter fields:

- `name`: 1–64 chars, lowercase unicode alphanumeric + hyphens only; MUST match the directory name.
- `description`: 1–1024 chars; MUST describe what the skill does *and* when to use it.

Recommended optional fields:

- `compatibility`: environment requirements (keep short)
- `metadata`: a map of string keys to string values (use for categories/tags/version/owner)

The Markdown body has no required structure, but SHOULD include:

- Step-by-step instructions
- Examples of inputs/outputs
- References to any bundled scripts/resources

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

Add a lightweight `skill-lint` GitHub Action that verifies:

- `SKILL.md` frontmatter exists and contains `name` + `description`
- `name` matches directory name and passes Agent Skills naming constraints
- `description` is non-empty

## Acceptance criteria

- [ ] `.github/skills/skill-template/SKILL.md` exists
- [ ] Initial skeletons for prioritized skills exist
- [ ] `skill-lint` workflow validates SKILL.md presence & required frontmatter

## Test cases

- Add a dummy skill folder missing required frontmatter and verify CI fails.
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